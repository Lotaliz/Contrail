---
id: tag-index
type: index
title: 标签索引
tags: [index, metadata]
status: active
---

# 标签索引

标签用于跨目录聚合实体；WikiLink 用于表达具体关系。点击标签可检索全部匹配页面，表中的链接只列代表页面。新增标签前先复用本页词表；确需新增时同步更新定义与分类。

## 使用原则

- 功能标签描述页面角色；技术标签描述论文的任务、模型/模态、机制和系统属性。
- 论文笔记通常使用多个技术标签，但只选择对跨论文检索有价值的标签。
- 不创建论文名、模型名、数据集名、会议名或单篇方法缩写标签。
- “论文数”按 `research/*/papers/*.md` 中当前 75 篇论文笔记统计；概念、综合和实验页不计入。

## 文档功能标签

| 标签 | 用途 |
|---|---|
| `#paper-note` | 论文阅读笔记 |
| `#research` | 研究项目、调研综合及论文记录 |
| `#method` | 算法或方法型页面 |
| `#technology` | 模型、架构和基础技术概念 |
| `#engineering` | 系统工程和基础设施；当前预留 |
| `#experiment` | 实验设计、执行和结果 |
| `#data` | 数据集、数据记录和统计 |
| `#writing` | 写作、表达和知识组织 |
| `#tool` | 可直接使用的软件或工具类别；当前预留 |
| `#index` | 导航或聚合页面 |
| `#metadata` | 规则、Schema 和维护信息 |
| `#workflow` | 研究与维护工作流 |
| `#source` | 原始来源登记或来源说明 |
| `#draft` | 尚未完成的内容；优先同时使用 `status: draft` |

## 安全任务与研究领域

| 标签 | 论文数 | 适用范围 | 代表页面 |
|---|---:|---|---|
| `#safety-guardrail` | 8 | 独立或外挂式输入、输出与多模态安全判别器 | [[LLM-Wiki/research/safety-classifier-compression/papers/2025-lee-harmaug.md\|HarmAug]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md\|SafeWatch]] |
| `#jailbreak-defense` | 4 | 针对 LLM 越狱的检测、阻断或干预 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-wang-selfdefend.md\|SelfDefend]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-liu-sentinel.md\|Sentinel]] |
| `#prompt-injection-defense` | 2 | 直接或间接提示注入的检测与系统隔离 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-zhong-rennervate.md\|Rennervate]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-li-ace.md\|ACE]] |
| `#content-moderation` | 4 | 平台或服务中的有害内容审核 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2024-wu-legilimens.md\|Legilimens]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhuang-hmguard.md\|HMGUARD]] |
| `#multimodal-safety` | 5 | 图像、视频、音频或跨模态安全问题 | [[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md\|SafeWatch]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-qu-vlm-unsafe-concepts.md\|VLM Unsafe Concepts]] |
| `#safety-alignment` | 4 | 安全对齐、对齐保持与恢复 | [[LLM-Wiki/research/safety-classifier-compression/papers/2026-fu-opsa-safety.md\|OPSA]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-yang-alignment-recovery.md\|Alignment Recovery]] |
| `#ai-agent-security` | 2 | LLM app、工具调用和多代理系统安全 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-li-ace.md\|ACE]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-syros-saga.md\|SAGA]] |
| `#platform-safety` | 2 | 真实产品、平台政策和治理效果 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-wei-character-platforms.md\|AI Character Platforms]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-gao-content-moderation-products.md\|Content Moderation Products]] |
| `#human-centered-security` | 2 | 用户体验、政策理解与社会技术安全 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-gao-content-moderation-products.md\|Content Moderation Products]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-wei-character-platforms.md\|AI Character Platforms]] |
| `#safety-evaluation` | 5 | 安全退化、鲁棒性、机制或产品效果的系统评估 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhang-activation-approximations.md\|Activation Approximations]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-zhang-bleeding-pathways.md\|Bleeding Pathways]] |

## 模型、模态与训练对象

| 标签 | 论文数 | 适用范围 | 代表页面 |
|---|---:|---|---|
| `#vision-language-model` | 16 | CLIP、VLM、MLLM 等图文模型 | [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-sparsevlm.md\|SparseVLM]]；[[LLM-Wiki/research/visual-token-pruning/papers/2024-devvrit-matformer.md\|MatFormer]] |
| `#multimodal-pretraining` | 3 | 图文预训练、强化数据和跨模态表征学习 | [[LLM-Wiki/research/visual-token-pruning/papers/2022-jiang-trips.md\|TRIPS]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2024-vasu-mobileclip.md\|MobileCLIP]] |
| `#model-compression` | 24 | 以更小参数量、结构或训练成本派生模型 | [[LLM-Wiki/research/safety-classifier-compression/papers/2024-muralidharan-minitron.md\|Minitron]]；[[LLM-Wiki/research/visual-token-pruning/papers/2024-devvrit-matformer.md\|MatFormer]] |

## 压缩、蒸馏与自适应计算机制

| 标签 | 论文数 | 适用范围 | 代表页面 |
|---|---:|---|---|
| `#visual-token-pruning` | 18 | 删除或选择视觉、视频及 VLM Token | [[LLM-Wiki/research/visual-token-pruning/papers/2024-chen-fastv.md\|FastV]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md\|SafeWatch]] |
| `#token-merging` | 4 | 通过聚合相似 Token 降低序列长度 | [[LLM-Wiki/research/visual-token-pruning/papers/2023-bolya-tome.md\|ToMe]]；[[LLM-Wiki/research/visual-token-pruning/papers/2023-cao-pumer.md\|PuMer]] |
| `#structured-pruning` | 15 | 层、头、宽度、FFN 或其他可执行结构剪枝 | [[LLM-Wiki/research/safety-classifier-compression/papers/2024-muralidharan-minitron.md\|Minitron]]；[[LLM-Wiki/research/visual-token-pruning/papers/2020-cai-once-for-all.md\|Once-for-All]] |
| `#unstructured-pruning` | 1 | 权重级非结构化或半结构化稀疏 | [[LLM-Wiki/research/safety-classifier-compression/papers/2024-sun-wanda.md\|Wanda]] |
| `#quantization` | 2 | 权重、激活或混合低比特近似 | [[LLM-Wiki/research/safety-classifier-compression/papers/2024-fedorov-llama-guard-int4.md\|Llama Guard INT4]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhang-activation-approximations.md\|Activation Approximations]] |
| `#knowledge-distillation` | 16 | 教师标签、Logit、特征、关系或轨迹蒸馏 | [[LLM-Wiki/research/safety-classifier-compression/papers/2025-lee-harmaug.md\|HarmAug]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2023-wu-tinyclip.md\|TinyCLIP]] |
| `#on-policy-distillation` | 8 | 在学生 rollout、前缀或生成状态上蒸馏 | [[LLM-Wiki/research/safety-classifier-compression/papers/2024-agarwal-gkd.md\|GKD]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2026-zhang-prefix-opd.md\|Prefix OPD]] |
| `#hard-example-mining` | 2 | 通过困难样本、错误反馈或数据生成补足决策边界 | [[LLM-Wiki/research/safety-classifier-compression/papers/2025-lee-harmaug.md\|HarmAug]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2024-palo-pgkd.md\|PGKD]] |
| `#budget-optimization` | 3 | 搜索或学习计算、层级或 Token 预算配置 | [[LLM-Wiki/research/visual-token-pruning/papers/2023-chen-diffrate.md\|DiffRate]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-ji-vispco.md\|VisPCO]] |
| `#dynamic-inference` | 14 | 按样本动态选择 Token、模块或计算路径 | [[LLM-Wiki/research/visual-token-pruning/papers/2023-cui-brainstorm.md\|Brainstorm]]；[[LLM-Wiki/research/visual-token-pruning/papers/2024-devvrit-matformer.md\|MatFormer]] |
| `#dynamic-sparsity` | 4 | 根据当前输入动态选择激活、神经元、头或细粒度子网 | [[LLM-Wiki/research/visual-token-pruning/papers/2023-liu-dejavu.md\|Deja Vu]]；[[LLM-Wiki/research/visual-token-pruning/papers/2024-raposo-mixture-of-depths.md\|Mixture-of-Depths]] |
| `#early-exit` | 1 | 从中间层提前产生预测或结束主干执行 | [[LLM-Wiki/research/visual-token-pruning/papers/2024-dai-apparate.md\|Apparate]] |
| `#model-routing` | 3 | 在多个模型、Guard 或共享子网路径之间选择执行 | [[LLM-Wiki/research/safety-classifier-compression/papers/2025-lee-saferoute.md\|SafeRoute]]；[[LLM-Wiki/research/visual-token-pruning/papers/2025-khare-superserve.md\|SuperServe]] |
| `#training-free` | 13 | 无需额外训练或微调的部署期方法 | [[LLM-Wiki/research/visual-token-pruning/papers/2024-chen-fastv.md\|FastV]]；[[LLM-Wiki/research/safety-classifier-compression/papers/2024-an-flap.md\|FLAP]] |
| `#test-time-adaptation` | 1 | 测试阶段利用当前输入进行无监督适应 | [[LLM-Wiki/research/visual-token-pruning/papers/2025-wang-tca.md\|TCA]] |
| `#hardware-aware-optimization` | 7 | 将设备时延、算子或端侧约束纳入优化 | [[LLM-Wiki/research/visual-token-pruning/papers/2023-dong-heatvit.md\|HeatViT]]；[[LLM-Wiki/research/visual-token-pruning/papers/2020-cai-once-for-all.md\|Once-for-All]] |

## 运行时、安全机制与评测属性

| 标签 | 论文数 | 适用范围 | 代表页面 |
|---|---:|---|---|
| `#efficient-inference` | 30 | 以真实时延、吞吐、内存或设备部署为主要目标 | [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-sparsevlm.md\|SparseVLM]]；[[LLM-Wiki/research/visual-token-pruning/papers/2024-raposo-mixture-of-depths.md\|Mixture-of-Depths]] |
| `#model-serving` | 8 | 面向在线推理服务的执行、调度、资源或反馈机制 | [[LLM-Wiki/research/visual-token-pruning/papers/2023-cui-brainstorm.md\|Brainstorm]]；[[LLM-Wiki/research/visual-token-pruning/papers/2025-khare-superserve.md\|SuperServe]] |
| `#continuous-batching` | 2 | 在运行中重组请求或按迭代/分块组织批执行 | [[LLM-Wiki/research/visual-token-pruning/papers/2022-yu-orca.md\|Orca]]；[[LLM-Wiki/research/visual-token-pruning/papers/2024-agrawal-sarathi-serve.md\|Sarathi-Serve]] |
| `#slo-aware-serving` | 4 | 以 deadline、尾时延或 SLO attainment/goodput 驱动在线调度 | [[LLM-Wiki/research/visual-token-pruning/papers/2024-dai-apparate.md\|Apparate]]；[[LLM-Wiki/research/visual-token-pruning/papers/2025-khare-superserve.md\|SuperServe]] |
| `#efficiency-evaluation` | 3 | 系统复核 FLOPs、近似与真实效率或安全之间的差异 | [[LLM-Wiki/research/visual-token-pruning/papers/2025-wen-token-pruning-right-problem.md\|Right Problem]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhang-activation-approximations.md\|Activation Approximations]] |
| `#representation-probing` | 4 | 从隐藏表示、跨层信号或共享表征进行检测与分析 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-liu-sentinel.md\|Sentinel]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhang-jbshield.md\|JBShield]] |
| `#activation-steering` | 2 | 在中间表示或生成过程中操控安全相关方向 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-zhang-jbshield.md\|JBShield]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-zhong-rennervate.md\|Rennervate]] |
| `#runtime-monitoring` | 4 | 在线输入、输出、隐藏状态或生成轨迹监控 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2025-wang-selfdefend.md\|SelfDefend]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2024-wu-legilimens.md\|Legilimens]] |
| `#policy-enforcement` | 3 | 将安全判定映射为可执行策略、阻断或治理动作 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-li-ace.md\|ACE]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-syros-saga.md\|SAGA]] |
| `#access-control` | 2 | 身份、能力和资源访问授权 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-li-ace.md\|ACE]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-syros-saga.md\|SAGA]] |
| `#information-flow-control` | 2 | 规划、数据和工具执行中的信息流约束 | [[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-li-ace.md\|ACE]]；[[LLM-Wiki/research/ai-safety-systems-security-venues/papers/2026-syros-saga.md\|SAGA]] |
