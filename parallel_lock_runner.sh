#!/bin/bash

# ====== 設定 ======
NPROC=${NPROC:-2}
LOCK_BASE="/tmp/$(basename "${0}").lock"
QUEUE_DIR="/tmp/$(basename "${0}").queue"
QUEUE_FILE="${QUEUE_DIR}/queue.$$"

mkdir -p "${QUEUE_DIR}"

# ====== クリーンアップ関数 ======
cleanup() {
    rm -f "${QUEUE_FILE}"
    if [[ -n "${ACQUIRED_LOCK_FD}" ]]; then
        eval "exec ${ACQUIRED_LOCK_FD}>&-"
    fi
}
trap cleanup EXIT HUP INT TERM

# ====== 古いキューファイル削除 ======
cleanup_stale_queue_files() {
    for file in "${QUEUE_DIR}"/queue.*; do
        [[ -e "${file}" ]] || continue
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
    if [[ "${first_queue}" == "${QUEUE_FILE}" ]]; then
        break
    fi
    sleep 1
done

# ====== 並列ロックの取得 ======
acquire_slot_lock() {
    for ((i=1; i<=${NPROC}; i++)); do
        lock_file="${LOCK_BASE}.${i}"
        eval "exec ${i}>"'"${lock_file}"'
        if flock -n "${i}"; then
            ACQUIRED_LOCK_FD="${i}"
            return 0
        else
            eval "exec ${i}>&-"
        fi
    done
    return 1
}

# ロック取得待機ループ
until acquire_slot_lock; do
    echo "[${$}] スロットが空くのを待機中..."
    sleep 1
done

# ====== メイン処理 ======
echo "[${$}] 開始: $(date '+%Y-%m-%d %H:%M:%S')"
sleep 10  # ★ここに本処理を記述
echo "[${$}] 終了: $(date '+%Y-%m-%d %H:%M:%S')"

# cleanup は trap で自動実行されます
