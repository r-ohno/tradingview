#!/bin/bash

RUN_NO=$1
# ====== 設定 ======
# NPROC: 並列実行数
NPROC=${NPROC:-2}
# ロックファイルベース名
LOCK_BASE="/tmp/$(basename "${0}").lock"
# キューファイル配置のディレクトリ
QUEUE_DIR="/tmp/$(basename "${0}").queue"
# キューファイルのパス
QUEUE_FILE="${QUEUE_DIR}/queue.$$"
# ログファイルのパス
LOG_FILE="/tmp/$(basename "${0}").log"

# ====== 初期化 ======
mkdir -p "${QUEUE_DIR}"

# ====== クリーンアップ関数 ======
cleanup() {
    if [ -n "${ACQUIRED_LOCK_FD}" ]; then
        eval "exec ${ACQUIRED_LOCK_FD}>&-"
    fi
    if [ -n "${ACQUIRED_LOCK_FILE}" ]; then
        rm -f "${ACQUIRED_LOCK_FILE}"
    fi
}
trap cleanup EXIT HUP INT TERM

# ====== 古いキューファイル削除 ======
cleanup_stale_queue_files() {
    for file in "${QUEUE_DIR}"/queue.*; do
        [ -e "${file}" ] || continue
        pid=$(basename "${file}" | cut -d. -f2)
        if ! kill -0 "${pid}" 2>/dev/null; then
            rm -f "${file}"
        fi
    done
}

# ====== 自分のキューファイル作成 ======
cleanup_stale_queue_files
touch "${QUEUE_FILE}"

# ====== FIFO順番待ち ======
while :; do
    cleanup_stale_queue_files
    first_queue=$(ls -t "${QUEUE_DIR}"/queue.* 2>/dev/null | tail -n 1)
    if [ "${first_queue}" = "${QUEUE_FILE}" ]; then
        echo "[${RUN_NO}][$$] キューに入っているのは自分だけです。処理を開始します。" >> "${LOG_FILE}"
        break
    fi
    sleep 1
done

# ====== 並列ロックの取得 ======
acquire_slot_lock() {
    for i in $(seq 1 ${NPROC}); do
        lock_file="${LOCK_BASE}.${i}"
        eval "exec ${i}>\"${lock_file}\""
        if flock -n "${i}"; then
            ACQUIRED_LOCK_FD="${i}"
            ACQUIRED_LOCK_FILE="${lock_file}"
            return 0
        else
            eval "exec ${i}>&-"
        fi
    done
    return 1
}

# ロック取得待機ループ
until acquire_slot_lock; do
    echo "[${RUN_NO}][$$] スロットが空くのを待機中..." >> "${LOG_FILE}"
    sleep 1
done
# ====== キューファイルを削除 ====== 
echo "[${RUN_NO}][$$] スロットを取得: ${ACQUIRED_LOCK_FILE}" >> "${LOG_FILE}"
rm -f "${QUEUE_FILE}"

# ====== メイン処理 ======
echo "[${RUN_NO}][$$] 開始: $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"
sleep 10  # ★ここに本処理を記述
echo "[${RUN_NO}][$$] 終了: $(date '+%Y-%m-%d %H:%M:%S')" >> "${LOG_FILE}"

# cleanup は trap で自動実行されます
