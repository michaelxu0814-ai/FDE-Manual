# 推送机制设计草稿（未创建，卡在缺 Telegram token/chat_id）

## 为什么不用别的机制

- `CronCreate`（会话内 cron）：只在当前会话内有效、7 天自动过期，撑不住 3 个月，排除。
- 本地 launchd（AOSC/AuShow 那套模式）：依赖 Mac 开机，用户明确说"工作的时候很难打开
  主对话界面"，如果 Mac 合盖/没开，当天的闪卡就发不出去，不满足"无时无刻可以触达"的要求，排除。
- 云端 routine（`RemoteTrigger`）：持久化、不依赖本地机器是否开机、最小间隔 1 小时——
  采用这个。缺点：routine 是无状态的云端 agent，每次触发都是"从零开始"，必须靠 git 仓库
  读写状态（progress.json）来知道该发哪张卡。

## 前置条件（卡点）

需要用户做这一步（Claude Code 无法代做，需要在 Telegram App 里操作）：
1. Telegram 里找 @BotFather，发 `/newbot`，按提示起个名字，拿到 bot token
2. 用户自己给这个新 bot 发一条任意消息（比如"hi"）
3. 浏览器打开 `https://api.telegram.org/bot<TOKEN>/getUpdates`，从返回的 JSON 里找
   `message.chat.id`，这就是 chat_id

拿到 token + chat_id 后，写入本仓库 `automation/telegram.env`（.gitignore 排除，不进
版本历史），再执行下面的创建步骤。

**安全提示（已告知用户）**：这个 token 会作为 routine 的运行时输入使用；因为 RemoteTrigger
目前没有独立的密钥管理字段，只能放在仓库里给云端 agent 读，不是最佳实践。因为这是个人单
用途的 bot（只发闪卡给一个 chat_id），风险可接受，但不要把这个仓库设为 public。

## Routine 配置草稿

- **cron（UTC）**：`3 0,3,6 * * 1-5` = 工作日 Brisbane 时间 10:03 / 13:03 / 16:03（错开整点）
- **repo**：github.com/michaelxu0814-ai/FDE-Manual
- **model**：claude-sonnet-5（推送任务不需要高推理成本）
- **allowed_tools**：Bash, Read, Write

## Routine Prompt 草稿

```
你在维护一个 Telegram 闪卡推送任务，仓库根目录有 phase-01/flashcards.json（题库）、
phase-01/progress.json（进度）、automation/telegram.env（TOKEN/CHAT_ID，source 一下拿到）。

按顺序做：

1. 读 progress.json 和 flashcards.json。
2. 如果 progress.json 的 sent_ids 还没覆盖 flashcards.json 里的全部卡片：
   a. 如果 last_sent_id 不为空，从 flashcards.json 里找到那张卡的 a（答案），
      先发一条消息："解析｜{上一题的 q 前十几个字}...\n{a}"
   b. 找到 sent_ids 里没有的下一张卡，发一条新消息："FDE闪卡 · Week {week}\n{q}"
      （只发问题，不带答案）
   c. 两条消息都用 curl 调 Telegram API：
      curl -s "https://api.telegram.org/bot${TOKEN}/sendMessage" \
        --data-urlencode "chat_id=${CHAT_ID}" --data-urlencode "text=消息内容"
   d. 把新发的卡片 id 加进 sent_ids，更新 last_sent_id 和 last_sent_at（用当前 UTC 时间），
      写回 progress.json
   e. git add/commit/push（commit message 就写 "chore: flashcard push {id}"，
      不要把 token 内容写进任何 commit 或输出）
3. 如果这一周的卡片已经全部发完，发一条消息 "本周闪卡已发完，等下周更新～"，
   然后什么都不用改、不要重复发送。
4. 只做闪卡推送这一件事，不要额外发挥、不要读写仓库里其他无关文件。
```

## 创建步骤（拿到 token 后执行）

1. `ToolSearch select:RemoteTrigger`
2. 把 telegram.env 写进仓库（先确认 .gitignore 排除它，避免进 git 历史；但 routine 需要
   能读到它——如果不想让敏感值进仓库，改成直接把 TOKEN/CHAT_ID 硬编码进 prompt 本身，
   两种方式都跟用户确认一下取舍）
3. `RemoteTrigger` action: create，body 按上面配置草稿填
4. 创建后 `action: run` 手动触发一次，`action: get_run_log` 确认真的发到 Telegram 了
5. 把结果记回 STATE.md
