---
id: ai-safety-systems-security-venues-comparison
type: synthesis
title: AI 安全系统顶会调研：统一比较
tags: [research]
project_id: ai-safety-systems-security-venues
sources: [paper-qu-2023-unsafe-diffusion, paper-he-2024-yopo, paper-wu-2024-legilimens, paper-li-2024-safegen, paper-wang-2024-moderator, paper-yang-2025-alignment-recovery, paper-wang-2025-selfdefend, paper-zhang-2025-jbshield, paper-qu-2025-vlm-unsafe-concepts, paper-zhang-2025-activation-approximations, paper-gao-2025-content-moderation-products, paper-zhuang-2025-hmguard, paper-qi-2025-safeguider, paper-wu-2026-enchtable, paper-li-2026-ace, paper-syros-2026-saga, paper-zhong-2026-rennervate, paper-zhang-2026-bleeding-pathways, paper-wei-2026-character-platforms, paper-liu-2026-sentinel, paper-paudel-2024-contextual-soft-moderation, paper-paudel-2024-pixelmod, paper-guo-2024-ugcg-guard, paper-kireev-2025-telegram-propaganda, paper-luo-2025-unsafe-search, paper-pang-2026-dualsentinel, paper-he-2026-attriguard, paper-shen-2025-hatebench, paper-lipphardt-2026-global-moderation, paper-qu-2024-unsafebench]
status: active
related: [ai-safety-systems-security-venues]
created: 2026-08-25
updated: 2026-10-21
---

# 统一比较

| 工作 | 信号/位置 | 动作 | 系统边界 | 压缩意义 |
|---|---|---|---|---|
| Legilimens | 概念特征 | 审核 | 服务 guard | 轻量统一检测 |
| SelfDefend | shadow LLM | checkpoint 阻断 | 并发双实例 | 适合蒸馏与级联 |
| JBShield | 激活概念 | 检测+操控 | 白盒 | 内部信号更丰富 |
| VLM Unsafe Concepts | 感知与对齐 | PPO | 模型级 | 保护跨模态一致性 |
| Activation Approximations | 近似误差 | QuadA | 部署链 | 压缩后安全复验 |
| HMGUARD | 领域/任务提示 + 表层、融合、构图、宣传、意图推理 | 二分类检测 | GPT-4V 多调用 guard；英文 meme | 同模型提示增益强，但未报告时延/成本；可按模块审计剪枝失效 |
| EnchTable | 安全向量 | 蒸馏+合并 | 发布链 | 安全恢复 |
| Sentinel | 多层 probe | 早期检测 | 白盒外挂 | 小于5M直接证据 |
| Rennervate | token attention | 检测+清洗 | 白盒运行时 | 细粒度干预 |
| DEEPALIGN | 中段隐藏状态 | steering | 白盒生成环 | 测 time-to-verdict |
| ACE / SAGA | 计划、信息流、策略 | 验证与授权 | 控制面 | guard 不替代控制面 |
| 产品审核 | 政策与角色 | 治理 | 社会技术系统 | 覆盖误拒与申诉 |

共同点：分离不可信语言与确定性执行；高风险动作使用 checkpoint、授权或 sanitization；同时测安全、utility 和系统开销。尚未统一：安全 taxonomy、固定 FPR 召回、计时边界、batch/流式吞吐、超时与版本更新降级。

## 2026-10-21阅读清单的比较边界

见[[LLM-Wiki/research/ai-safety-systems-security-venues/moderation-reading-list-2024-2026.md|23篇标题/来源/主题入口]]。本轮只比较审核对象与机制位置，不合并摘要中的效果或计时数字：

| 对象 | 新检索代表 | 判别依据/干预位置 | 不能混同的指标 |
|---|---|---|---|
| 帖子是否支持错误主张 | CTD | 文本立场；既有软审核管线 | 语境误报不等于整体有害内容准确率 |
| 待补标签的误导图片 | PIXELMOD | 哈希、OCR与检索 | 近邻检索召回不等于通用VLM政策判断 |
| 游戏推广图片 | UGCG-Guard | 条件提示与VLM情境推理 | 领域检测不等于开放世界图片审核 |
| 搜索回答及URL | Unsafe LLM-Based Search | 内容精炼与URL检测 | 回答安全与恶意URL识别是不同环节 |
| 宣传账号 | Telegram检测 | 正常消息与宣传回复关系 | 账号检测不是单句毒性分类 |
| 定向payload输出 | DualSentinel | token概率熵与任务翻转 | 不保证覆盖全部语义风险或任意API访问条件 |
| 工具调用 | AttriGuard | 反事实动作归因与shadow replay | 行为授权不等于输入内容Safe/Unsafe |

另校正Moderator属于政策驱动的生成模型权重编辑，不能与在线prompt改写器混同。新条目维持discovered，完整训练成本、推理边界、攻击自适应性和复现情况待用户选读后核验。
