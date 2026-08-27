# STATE — 驻场手册 (FDE 三月纲要)

> 每次会话开场先读本文件。完整纲要见 README.md，本周任务见 phase-01/week-0N-tasks.md。

最后更新：2026-08-28

## 这是什么

用户（GM，健身器材公司，零代码基础）的 3 个月 FDE（AI 落地方向）能力养成计划。
目标：3 个月后能独立接住一个客户的 AI 落地需求，走完摸底→判断→搭建→验收→交付，
不靠人手把手指导。纲要设计过程见对话记录，已发布 Artifact：
https://claude.ai/code/artifact/bc6e384e-4c69-4b40-9043-1baa80085681

## 进度

- [x] 2026-08-16 纲要确认（五步方法论 + 固定技术骨架 Python/Claude API/SQLite+Pandas/Streamlit/Railway/Git + 三段模拟客户）
- [x] 2026-08-16 Phase 01 Week 1 任务 + 首批闪卡完成
- [x] 2026-08-18 本地 launchd + Telegram 推送机制跑通（取代云端 Gmail 方案，见下）
- [x] 2026-08-18~20 Week 1 的 10 张卡发完
- [ ] 08-21~27 断推一周（见"故障复盘"）
- [x] 2026-08-28 补充 Week 2-4 课程与题库，推送恢复（w1-10 解析 + w2-01 已补发）
- [ ] Week 2 进行中：phase-01/week-02-tasks.md（RAG 搭建）

## 推送机制（最终方案）

**本地 launchd + Telegram bot（t.me/FDE2026_BOT）。** 不是云端 routine，不是邮件。

- 任务：`~/Library/LaunchAgents/com.fdemanual.flashcard.plist` → `automation/send_flashcard.sh`
- 时间：工作日 10:03 / 13:03 / 16:03（脚本内判断周末跳过）
- 逻辑：读 `phase-01/flashcards.json` + `progress.json`；每次触发先发上一张卡的"解析"，
  再发下一张未发的新题；`send_msg` 用 Telegram API 返回 HTTP 码，**两条都 200 才推进进度**
  （发送失败不推进，下次自动重试，不会静默丢卡）；随后 git add/commit/push `progress.json`。
- 密钥：`automation/telegram.env`（gitignore），token/chat_id 见该文件。
- 周次标签：从卡片 id（`w2-01`）自动推导，跨周无需手动改。
- **依赖本地 Mac 开机**。用户已确认通常开着；若某次关机错过推送，开机后下一次触发会继续
  （脚本无状态补偿，补发上一张解析）。

### 为什么不用云端 routine（历史）

最早尝试云端 routine + Telegram：云端沙盒出网白名单不含 api.telegram.org（403 CONNECT），
排除。PushNotification/Remote Control 需要本地活跃会话，云端独立触发推不到手机，排除。
用 Gmail MCP 发邮件那条路曾经跑通过（routine `trig_01WqFq2oP9jkSELV75hLiNpu`），但
用户后来又建了 Telegram bot，本地 launchd 直连 Telegram 更直接，成为最终方案。

**遗留：云端 Gmail routine `trig_01WqFq2oP9jkSELV75hLiNpu` 可能仍在启用**，与本地
Telegram 双通道同时发会重复。若它还在跑，去 https://claude.ai/code/routines 停用。

## 故障复盘（2026-08-21~27 断推一周）

- 现象：Telegram 一周没收到闪卡。launchd 每天正常触发，日志每天打"本周已发完，已通知过，跳过"。
- 根因：**不是机制坏了，是内容断了**。`flashcards.json` 只有 Week 1 的 10 张卡，8-20 发完后
  脚本按设计进入"等下周更新"；但 Week 2 的课程和闪卡从来没被写出来，于是静默一周。
- 教训：这套陪伴学习的内容必须**主动维护**。本期一次性把 Week 2-4 的 tasks + 闪卡（45 张）
  都补齐了，按工作日 3 次/天算大约 15 张/周，正好匹配。之后每周内容提前批量生成，
  不要让"下周更新"变成无人兑现的承诺。

## 仓库

github.com/michaelxu0814-ai/FDE-Manual（**public**，学习项目内容不敏感）。
git push 用显式 token URL（macOS keychain 的 gh token 是旧的）：
`https://michaelxu0814-ai:<gh auth token>@github.com/michaelxu0814-ai/FDE-Manual.git`

## 关键约束（勿忘）

- 技术骨架固定，不随 phase 换：Python + Claude API + SQLite/Pandas + Streamlit + Railway/Vercel + Git + Claude Code
- 3 段模拟客户与用户现有工作（健身器材公司）完全脱钩，避免混淆
- 每天 1 小时深度 session 是核心学习场景；闪卡推送只是轻量巩固，量级可调
- 闪卡节奏约 15 张/周（3 次/天 × 5 工作日），内容先备足，别让推送断
