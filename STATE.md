# STATE — 驻场手册 (FDE 三月纲要)

> 每次会话开场先读本文件。完整纲要见 README.md，本周任务见 phase-01/week-01-tasks.md。

最后更新：2026-08-16

## 这是什么

用户（GM，健身器材公司，零代码基础）的 3 个月 FDE（AI 落地方向）能力养成计划。
目标：3 个月后能独立接住一个客户的 AI 落地需求，走完摸底→判断→搭建→验收→交付，
不靠人手把手指导。纲要设计过程见对话记录，已发布 Artifact：
https://claude.ai/code/artifact/bc6e384e-4c69-4b40-9043-1baa80085681

## 进度

- [x] 2026-08-16 纲要确认（五步方法论 + 固定技术骨架 Python/Claude API/SQLite+Pandas/Streamlit/Railway/Git + 三段模拟客户）
- [x] 2026-08-16 Phase 01 Week 1 任务拆解 + 首批闪卡完成
- [ ] 推送机制未搭建——**卡在需要用户提供 Telegram bot token + chat_id**，见下方「待办」
- [ ] Week 1 尚未开始执行

## 待办（下次会话先看这里）

**推送机制卡点**：cron 工具（CronCreate）是会话级、7天过期，不能撑 3 个月；已确认改用
云端 routine（RemoteTrigger，cron 最小间隔 1 小时，持久化，不依赖本地 Mac 开机）+ Telegram
bot 做每日闪卡推送。routine 是无状态的，每次触发都要从这个仓库读取 phase-01/progress.json
判断该发哪张卡、发送后更新进度并 commit。

卡住的地方：需要用户在 Telegram 里跟 @BotFather 走一遍 /newbot 拿到 token，并给 bot 发一条
消息后从 `https://api.telegram.org/bot<TOKEN>/getUpdates` 取 chat_id。拿到这两个值后：
1. 把 token/chat_id 写进本仓库（或直接嵌入 routine 的 prompt——仅个人使用，风险可接受，
   但已跟用户说明这不是最佳安全实践）
2. 用 RemoteTrigger 创建 routine，prompt 设计草稿见 automation/routine-design.md
3. 建议 cron：工作日 (1-5) 每天 3 次，间隔 ≥1 小时（示例见 routine-design.md），Brisbane 本地时间需转 UTC

## 仓库

github.com/michaelxu0814-ai/FDE-Manual （待确认是否已 push；用 michaelxu0814-ai 账号，
个人学习项目，非某个具体公司/生意）

## 关键约束（勿忘）

- 技术骨架固定，不随 phase 换：Python + Claude API + SQLite/Pandas + Streamlit + Railway/Vercel + Git + Claude Code
- 3 段模拟客户与用户现有工作（健身器材公司）完全脱钩，避免混淆
- 每天 1 小时深度 session 是核心学习场景；闪卡推送只是轻量巩固，前期先跑，量级可调
