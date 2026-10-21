---
id: ai-safety-systems-security-venues-reading-log
type: synthesis
title: AI 安全系统顶会调研：检索与阅读日志
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel, code-qu-2025-safervlm-audit, webpage-qu-2025-unsafeconcepts-card, webpage-usenix-security-2025-cfp, webpage-usenix-security-2026-cfp-ml, paper-paudel-2024-contextual-soft-moderation, paper-paudel-2024-pixelmod, paper-guo-2024-ugcg-guard, paper-kireev-2025-telegram-propaganda, paper-luo-2025-unsafe-search, paper-pang-2026-dualsentinel, paper-he-2026-attriguard, paper-shen-2025-hatebench, paper-lipphardt-2026-global-moderation, paper-qu-2024-unsafebench]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-10-21
---

# 检索与阅读日志

## 2026-10-21：2024—2026年审核系统阅读入口扩展

按用户“提供标题、来源、主题，由用户自行阅读”的要求，建立[[LLM-Wiki/research/ai-safety-systems-security-venues/moderation-reading-list-2024-2026.md|23篇分组清单]]：10篇直接审核/生成控制、8篇运行时Guard/Agent控制、5篇明确标注的基准/平台测量。会议年与预印本年分开，不重复Qu2025已读论文，不将受邀演讲或攻击主导论文算成防护系统。★仅是个人阅读顺序，不是实测排名。

复用14条既有论文来源（含其他项目的UnsafeBench），新登记9条discovered题录：CTD、PIXELMOD、UGCG-Guard、Telegram宣传账号检测、Unsafe LLM-Based Search、DualSentinel、2026 AttriGuard、HateBench和跨地区/语言审核测量。核验官方摘要/BibTeX和会议列表，不将新条目标为skimmed/deep-read；未下载原件、执行模型或推导正式研究缺口。

检索站点包括S&P2024/2025/2026接收页、CCS2024/2026接收页、NDSS2026接收页及2025独立论文页、USENIX2024/2025/2026独立论文页/日程。关键词族为content moderation、soft moderation、toxic content、guard、unsafe、safety、policy、propaganda、agent。CCS2025接收整页不可访问，用作者项目页/BibTeX与作者v3会议声明补核SafeGuider/UnsafeBench；出版商DOI403，部分USENIX日程超时，Telegram最终PDF31.8MB超过网页抓取限制，未核定其具体模型细节。未发现关键词不能证明某届会议无相关论文。

同步项目、机制地图和比较入口，校正Moderator为政策驱动权重编辑并补齐两位遗漏作者。历史20篇集合/覆盖计数仅标为历史，不以新清单重算；不改正式motivation、gaps或既有实验。按wiki-finalize收尾。

## 2026-10-20：UnsafeConcepts 域外迁移、贡献与提示复核

在既有[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-qu-vlm-unsafe-concepts.md|论文笔记]]补答三项追问，回查§5.4–5.5、表1/3/5及附录KL消融。只读固定版本官方 `scripts/eval.sh`、`eval_rlhf.py` 和 `unsafe_datasets.py`，确认同一adapter跨主集/SMID/NSFW直接推理，无域外重训练；主审核与域外审核同用五类问题，每图固定seed随机选一种，不能解释成未见prompt或政策泛化。

区分已有PPO的任务化简化与算法发明，将测量/数据/修复的贡献排序标为个人判断；指出缺少KL不使SFT退化成为必然，现有模板对照未控制约束与监督形式，PPO内KL消融不能替代受约束SFT基线。沿用现有来源，不新增论文/概念/实验；未运行模型或下载受限数据。

## 2026-10-20：UnsafeConcepts 四项追问核验

围绕数据构造/格式、辅助奖励、训练评测与SFT目标、USENIX投稿范围，在既有[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-qu-vlm-unsafe-concepts.md|论文笔记]]追加问答，沿用唯一论文/代码来源，不另建论文或方案。只读官方公开JSONL确认1567行/75概念，按per-concept floor80%规则静态推得1222训练/345测试不安全图；按论文等量safe设定对应2444训练和690测试，未运行数据构造或核验生成文件。

核对SFT预处理的instruction masking与完整模板/正确概念监督，确认PPO奖励仅接收回答及二元标签，不直接评估概念或图像解释。区分五类评测用途、域内分类与解释/通用能力折中。新增官方HF数据卡和2025 CFP来源，复用并回查2026 CFP，确认AI应用于安全与AI自身安全均可在范围内；文章的威胁意义按公开§5.1解读，程序委员会真实接受理由未知。wiki-finalize收尾，不修改正式动机或实验结果。

## 2026-10-20：UnsafeConcepts 场景与 PPO 方法再精读

用户指定 [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-qu-vlm-unsafe-concepts.md|Bridging the Gap in Vision Language Models in Identifying Unsafe Concepts Across Modalities]]；复用既有稳定论文 ID、21 页原件及笔记，维持 deep-read / source-checked。核对 §1–7、附录 A.1–A.2、图 1–12、表 1–7 和公式 (3)–(4)，用 PDF 技能视觉复核测量提示、PPO 奖励、主表及消融。未运行模型或下载受限图像数据。

补充通俗入口：图像审核输入/输出、概念识别与适宜性判断的区别、空白图+显式概念文本的对照局限；解释 PPO 的 rollout→响应分类→奖励→策略更新，以及分类正确、长度、熵和 KL 各自的作用。只读官方固定 revision `22632cf1b1d0a91dba8541df95a8d400fc59db52`，新增 `code-qu-2025-safervlm-audit`，确认冻结视觉塔/projector、语言侧 LoRA、奖励 batch 归一化、概念内图像切分和 adapter 合并推理；源码与论文实验版本同一性待核。

区分 SFT 分类最高与 PPO 解释/通用能力折中，分别记录危险识别提升和安全误报增加；补正不同测量中的拒答/N/A 规则，指出文字感知提示、原奖励代理及模板基线的边界。与当前政策条件 Guard 的关系只列候选判断，不修改正式动机、压缩方案或既有实验。主题范围未扩展成新文献综述。

检索四会官方 accepted papers、program、technical sessions、paper pages 与 proceedings。查询覆盖 LLM、generative AI、multimodal、text-to-image、agent 与 safety、alignment、moderation、toxic、harmful、guard、detection、governance。先记录 discovered 候选，再按“直接安全目标、主会、非攻击主导”筛选。

## 2026-08-25历史核心集合（20篇）

| 年份 | 会议 | 论文 | 角色 | 级别 |
|---|---|---|---|---|
| 2023 | CCS | Unsafe Diffusion | 文生图风险测量/检测 | skimmed |
| 2024 | S&P | You Only Prompt Once | 毒性分类、span、detox | skimmed |
| 2024 | CCS | Legilimens / SafeGen / Moderator | LLM 与 T2I 内容审核 | Legilimens：skimmed；其余沿用原级别 |
| 2025 | S&P | Alignment Recovery | 微调后参数恢复 | skimmed |
| 2025 | USENIX | SelfDefend / JBShield | 运行时与隐状态 guard | skimmed |
| 2025 | USENIX | VLM Unsafe Concepts | 跨模态安全对齐 | deep-read |
| 2025 | USENIX | Activation Approximations | 近似后的安全退化 | skimmed |
| 2025 | USENIX | I Cannot Write This | 产品政策/体验 | skimmed |
| 2025 | NDSS | HMGUARD | 有害 meme 检测 | deep-read |
| 2025 | CCS | SafeGuider | T2I 安全控制 | discovered |
| 2026 | S&P | EnchTable | 安全迁移/合并 | skimmed |
| 2026 | NDSS | ACE / SAGA | app 与 agent 架构 | skimmed |
| 2026 | NDSS | Rennervate / DEEPALIGN | token/生成中干预 | skimmed |
| 2026 | NDSS | AI Character Platforms | 平台安全审核 | skimmed |
| 2026 | USENIX | Sentinel | 小于5M隐藏状态检测器 | deep-read |

## 历史核心集合覆盖计数（非2026-10-21清单）

| 会议 | 2023 | 2024 | 2025 | 2026 | 合计 |
|---|---:|---:|---:|---:|---:|
| IEEE S&P | 0 | 1 | 1 | 1 | 3 |
| USENIX Security | 0 | 0 | 5 | 1 | 6 |
| ACM CCS | 1 | 3 | 1 | 0 | 5 |
| NDSS | 0 | 0 | 1 | 5 | 6 |

“0”表示严格口径未找到，不表示没有 AI/ML security 论文。CCS 2026 的两个仅官方接收候选未计入核心集合。

## 2026-08-25 中文泛读复核

- 对 `papers/` 下现有 14 篇独立论文笔记重新核对摘要、引言、方法概览、主要实验与结论。
- 14 篇笔记统一标记为 `reading_level: skimmed`，正文改写为中文，并补齐研究问题、方法、主要结果、局限、项目关联和是否值得精读的判断。
- 未为核心集合中尚无独立笔记的 6 篇论文新增笔记；其既有阅读级别保持不变。
- 本轮未复现实验；论文数字仅记录在原文设定下可核验的结果，不做跨论文时延或准确率拼接。

## 2026-08-25 两篇论文精读

- 将 [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-liu-sentinel.md|Sentinel]] 升级为 `deep-read`：重点核对逐层探针、ACI、多层去冗余融合、自适应白盒攻击和效率计时边界，并明确 probe 可分性不等于因果认知。
- 将 [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-qu-vlm-unsafe-concepts.md|VLM Unsafe Concepts]] 升级为 `deep-read`：重点核对 UnsafeConcepts 构建、感知—对齐分解、跨模态差距、情境分析、简化 PPO 及 SFT/DPO 比较边界。
- 两篇论文的共同结构是“输入信息已被部分识别，但安全策略未稳定执行”：一篇沿模型深度研究识别—执行缺口，另一篇沿输入模态研究感知—对齐缺口。

## 2026-09-08 HMGUARD 精读

- 将 [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhuang-hmguard.md|HMGUARD]] 升级为 `deep-read`，按“任务场景—失效测量—HMCOT 设计—主结果—消融—实景与鲁棒性”重构笔记。
- 论文把 harmful meme 检测分解为表层含义、图文融合、多格构图、宣传技巧和攻击意图五类推理，并用 meme 领域对齐与审核任务适配作为前置提示。
- 同一 GPT-4V 基础模型上，结构化提示相对通用单问在 FHM 的 Accuracy/F1 从 0.61/0.60 提升至 0.86/0.85，在 HarMeme 从 0.74/0.69 提升至 0.92/0.91；但表 VI 的多个 Precision/Recall/F1 三元组数学上不一致，精确指标比较需保留警告。
- 对当前多模态 Guard 研究的直接价值是提供模块级失效坐标；尚缺端到端时延/成本、固定版本复现、多次运行、跨语言和广义对抗鲁棒证据。
