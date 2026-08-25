---
id: safety-classifier-compression-landscape
type: synthesis
title: 安全判别剪枝与蒸馏技术路线图
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-muralidharan-2024-minitron, paper-sun-2024-wanda, paper-xia-2024-sheared-llama, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-wu-2023-tinyclip, paper-yang-2024-clip-kd, paper-vasu-2024-mobileclip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety]
status: active
created: 2026-08-24
updated: 2026-08-25
---

# 技术路线图

## 1. 从生成式 Guard 蒸馏到任务专用判别器

核心变化是把“生成 safe/unsafe 文本”改成一次 encoder forward 的分类头。HarmAug 以 Llama-Guard-3 标注指令—响应对，训练 435M DeBERTa；PGKD 在普通多分类中让教师根据学生验证错误和 hard negatives 继续造数据。该路线的主要收益来自更小架构和更短输出，主要风险是类别尾部、策略变化与教师偏差被固化。

## 2. 剪枝后用蒸馏恢复，而非二选一

Llama Guard 3-1B-INT4、Minitron 与 Sheared LLaMA 共同支持“先确定目标 dense 形状，再恢复知识”。主流结构维度包括层深、attention heads、FFN neurons 与 embedding width。Minitron 表明激活统计可用少量校准样本排序结构；蒸馏在同等计算预算下优于普通继续训练。

## 3. 任务感知的先剪后调

P-pruning 用目标任务的无标签输入先聚类 attention head 与 neuron 输出，再保留代表模块，随后只微调较小子网。对经常更新安全 taxonomy 的系统，这比“每个任务先完整微调大模型再剪”更可能节省累计训练成本，但子网具有明显任务特异性，策略迁移时需重新校准。

## 4. 免训练稀疏与可部署结构

Wanda 用权重幅值乘输入激活选择稀疏权重，几乎不需恢复训练；优点是压缩准备成本低，局限是非结构化稀疏只有在 kernel、编译器和硬件支持时才能转成吞吐。生产判别器更稳妥的默认仍是结构化 dense 子网，半结构化 N:M 可作为硬件已支持时的第二选择。

## 5. 多模态关系蒸馏

TinyCLIP 模仿图文 affinity 并继承教师权重；CLIP-KD 显示简单 feature MSE 是很强的基线；MobileCLIP 把教师 embedding 和合成 caption 离线写入 reinforced dataset，避免每次训练都在线运行教师。路线重点从 Logit 迁移到跨模态几何关系和可复用离线监督。

## 6. 多模态结构与 Token 联合剪枝

MoPE-CLIP 用跨模态任务性能下降估计 head、FFN 和层的重要性；SmartTrim 按样本动态剪 Token 和 attention heads，并以 full-capacity 路径自蒸馏；VisionZip 在大型生成式 VLM 中选择少量 dominant/contextual visual tokens。对安全审核，视觉 Token 剪枝必须额外保护 OCR、小目标、隐蔽符号和图文组合才成立。

## 7. Policy-aware Token 剪枝与归因生成

SafeWatch 将每条安全政策作为 visual-token selector 的查询，在视频 Guard 中按 policy—video cross-attention 保留 Top-k token，再自回归生成视频描述、多标签判定和逐政策解释；其专门的剪枝适应训练说明部署时直接套通用 Top-k 并不稳妥。该路线可减少视觉前缀、后续 attention 与 KV cache，但无法消除解释文本的顺序 decode 成本；还需要用证据定位与删除/插入测试区分“流畅解释”和“忠实归因”。

## 8. 表征复用与大小模型级联

MULTIGUARD 从正在运行的 LLM/MLLM 隐层提取跨语言/模态共有表征，再训练轻量分类器；只有当主模型 forward 本来就会发生时，其约 120× 的分类器速度优势才可视为增量开销。SafeRoute 则把大 Guard 保留为困难样本后备。二者代表部署侧的主流：复用已有计算、避免所有请求都走最强 Guard。

## 9. 学生 rollout 上的 On-policy 蒸馏

GKD 将固定序列与当前学生 rollout 混合；MiniLLM、DistiLLM 和 Veto 分别围绕 reverse KL、skew KL 与目标重构处理训练稳定性；Prefix OPD 只蒸馏长推理前缀以降低成本。对会输出 verdict/category/rationale 的自回归 Guard，这条路线可在学生真实错误前缀上施教；对一次前向的 encoder Guard，学生错误驱动的困难样本采集只是相邻范式，不是严格 on-policy。OPSA 提供安全对齐直接证据，但仍为预印本且未验证独立多模态 Guard。

## 综合判断

当前最可信的组合不是单点算法，而是“任务专用学生 + 结构化目标形状 + 尾部数据蒸馏 + 真实硬件编译 + 困难样本级联”。On-policy 蒸馏可作为自回归 Guard 的增量候选，而非默认替代静态 KD。安全精度需要按类别召回、FPR、校准和攻击变体评估；效率需要把学生 rollout、教师调用、数据生成、恢复训练、路由器和大模型回退全部计入。
