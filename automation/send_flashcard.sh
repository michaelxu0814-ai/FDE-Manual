#!/bin/zsh
# FDE-Manual 闪卡推送:发到 Telegram bot t.me/FDE2026_BOT。
# 由 launchd 工作日 10:03/13:03/16:03 调用(com.fdemanual.flashcard),脚本自己判断周末跳过。
# 也可手动跑: ./send_flashcard.sh
cd "$(dirname "$0")/.."
mkdir -p logs
LOG="logs/$(date +%F).log"
source automation/telegram.env

exec >> "$LOG" 2>&1
echo "===== send_flashcard $(date '+%F %T') ====="

# 周末不发(1=周一...7=周日)
DOW=$(date +%u)
if [ "$DOW" -ge 6 ]; then
  echo "周末，跳过"
  exit 0
fi

FLASHCARDS="phase-01/flashcards.json"
PROGRESS="phase-01/progress.json"

TOTAL=$(jq '.cards | length' "$FLASHCARDS")
SENT_COUNT=$(jq '.sent_ids | length' "$PROGRESS")

send_msg() {
  curl -s -o /dev/null -w '%{http_code}' "https://api.telegram.org/bot${TELEGRAM_TOKEN}/sendMessage" \
    --data-urlencode "chat_id=${TELEGRAM_CHAT_ID}" \
    --data-urlencode "text=$1"
}

if [ "$SENT_COUNT" -lt "$TOTAL" ]; then
  LAST_ID=$(jq -r '.last_sent_id' "$PROGRESS")
  if [ "$LAST_ID" != "null" ]; then
    LAST_A=$(jq -r --arg id "$LAST_ID" '.cards[] | select(.id == $id) | .a' "$FLASHCARDS")
    C1=$(send_msg "解析｜${LAST_A}")
    echo "发了 ${LAST_ID} 的解析 [HTTP ${C1}]"
  fi

  NEXT=$(jq -r --slurpfile p "$PROGRESS" \
    '.cards[] | select(.id as $id | ($p[0].sent_ids | index($id)) == null) | .id' "$FLASHCARDS" | head -1)

  if [ -n "$NEXT" ]; then
    Q=$(jq -r --arg id "$NEXT" '.cards[] | select(.id == $id) | .q' "$FLASHCARDS")
    WEEK_LABEL=$(echo "$NEXT" | sed 's/^w\([0-9]*\)-.*/\1/')
    C2=$(send_msg "FDE闪卡 · Week ${WEEK_LABEL}
${Q}")
    echo "发了 ${NEXT} [HTTP ${C2}]"

    if [ "${C1:-0}" = "200" ] && [ "${C2:-0}" = "200" ]; then
      NOW=$(date -u +%Y-%m-%dT%H:%M:%SZ)
      jq --arg id "$NEXT" --arg t "$NOW" \
        '.sent_ids += [$id] | .last_sent_id = $id | .last_sent_at = $t' \
        "$PROGRESS" > "${PROGRESS}.tmp" && mv "${PROGRESS}.tmp" "$PROGRESS"

      git add "$PROGRESS"
      git commit -m "chore: flashcard push ${NEXT}" > /dev/null
      if git push "https://michaelxu0814-ai:$(gh auth token -u michaelxu0814-ai)@github.com/michaelxu0814-ai/FDE-Manual.git" HEAD:main; then
        echo "pushed"
      else
        echo "push FAILED(继续,下次再试)"
      fi
    else
      echo "发送未成功(C1=${C1:-空} C2=${C2:-空})，不推进进度，下次重试"
    fi
  fi
else
  NOTIFIED=$(jq -r '.week_complete_notified // false' "$PROGRESS")
  if [ "$NOTIFIED" != "true" ]; then
    C=$(send_msg "本周闪卡已发完，等下周更新～")
    echo "已发完通知 [HTTP ${C}]"
    if [ "$C" = "200" ]; then
      jq '.week_complete_notified = true' "$PROGRESS" > "${PROGRESS}.tmp" && mv "${PROGRESS}.tmp" "$PROGRESS"
      git add "$PROGRESS"
      git commit -m "chore: week complete notified" > /dev/null
      git push "https://michaelxu0814-ai:$(gh auth token -u michaelxu0814-ai)@github.com/michaelxu0814-ai/FDE-Manual.git" HEAD:main
      echo "本周已发完，已通知"
    else
      echo "通知发送失败，保持未通知状态，下次再试"
    fi
  else
    echo "本周已发完，已通知过，跳过"
  fi
fi
