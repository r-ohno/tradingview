#!/bin/bash

# 並列数
NPROC=${NPROC:-2}  
# ロックファイル
LOCK_NAME="/tmp/$(basename "$0").lock"
# キュー管理ディレクトリ
QUEUE_DIR="/tmp/$(basename "$0").queue"
# キューファイル
QUEUE_FILE="${QUEUE_DIR}/queue.$$"


# ====== 初期化 ======
mkdir -p "${QUEUE_DIR}"

# ====== ロック監視（タイムアウトなし）=====
cleanup_stale_locks() {
    for file in "${QUEUE_DIR}"/queue.*; do
        [[ -e "${file}" ]] || continue
        pid=$(basename "$file" | cut -d. -f2)
        if ! kill -0 "${pid}" 2>/dev/null; then
            echo "[監視] 終了済みプロセスのロックを削除: ${file}"
            rm -f "${file}"
        fi
    done
}

cleanup_stale_locks

# ====== 自分の順番ファイル作成 ======
touch "${QUEUE_FILE}"

# ====== FIFO順待機 ======
while :; do
    cleanup_stale_locks
    first_lock=$(ls -t "${QUEUE_DIR}"/lock.* 2>/dev/null | tail -n 1)
    if [[ "$first_lock" == "${QUEUE_FILE}" ]]; then
        break
    fi
    sleep 1
done

# ====== 並列制限付き実行（flock）=====
(
    exec 200>"${LOCK_NAME}"

    if ! flock -n 200; then
        echo "[INFO] 最大並列数に達しているため待機..."
        flock 200  # ブロッキングモード
    fi

    echo "[$$] 開始: $(date '+%Y-%m-%d %H:%M:%S')"

    ############################
    # ▼ ここに処理を記述 ▼
    sleep 10  # ← 本番処理に変更
    ############################

    echo "[$$] 終了: $(date '+%Y-%m-%d %H:%M:%S')"

) 200>"${LOCK_NAME}"

# ====== 自分のロックファイル削除 ======
rm -f "${QUEUE_FILE}"
