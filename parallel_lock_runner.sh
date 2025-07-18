#!/bin/bash

# ====== 設定 ======
NPROC=${NPROC:-2}
LOCK_FILE="/tmp/$(basename "${0}").lock"
QUEUE_DIR="/tmp/$(basename "${0}").queue"
MY_QUEUE_FILE="${QUEUE_DIR}/queue.$$"

mkdir -p "${QUEUE_DIR}"

# ====== クリーンアップ関数 ======
cleanup() {
    rm -f "${MY_QUEUE_FILE}"

    # キューが空ならロックファイル削除
    if [[ ! $(ls "${QUEUE_DIR}"/queue.* 2>/dev/null) ]]; then
        rm -f "${LOCK_FILE}"
    fi
}

# ====== trap設定 ======
trap cleanup EXIT HUP INT TERM

# ====== 古いキューの掃除 ======
cleanup_stale_queue_files() {
    for file in "${QUEUE_DIR}"/queue.*; do
        [[ -e "${file}" ]] || continue
        pid=$(basename "${file}" | cut -d. -f2)
        if ! kill -0 "${pid}" 2>/dev/null; then
            rm -f "${file}"
        fi
    done
}

# ====== 自分の順番待ちファイル作成 ======
cleanup_stale_queue_files
touch "${MY_QUEUE_FILE}"

# ====== 順番が来るまで待機 ======
while :; do
    cleanup_stale_queue_files
    first_queue=$(ls -t "${QUEUE_DIR}"/queue.* 2>/dev/null | tail -n 1)
    if [[ "${first_queue}" == "${MY_QUEUE_FILE}" ]]; then
        rm -f "${MY_QUEUE_FILE}"
        break
    fi
    sleep 1
done

# ====== 並列数制限付きで実行 ======
(
    exec 200>"${LOCK_FILE}"

    if ! flock -n 200; then
        echo "[${$}] 並列数上限のため待機中..."
        flock 200  # ブロック待ち
    fi

    ############################
    echo "[${$}] 開始: $(date '+%Y-%m-%d %H:%M:%S')"
    sleep 10
    echo "[${$}] 終了: $(date '+%Y-%m-%d %H:%M:%S')"
    ############################

) 200>"${LOCK_FILE}"
