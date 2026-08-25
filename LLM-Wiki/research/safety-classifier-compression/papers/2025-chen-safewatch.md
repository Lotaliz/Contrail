---
id: paper-note-chen-2025-safewatch
type: paper-note
title: "SafeWatch: An Efficient Safety-Policy Following Video Guardrail Model with Transparent Explanations"
authors: ["Zhaorun Chen", "Francesco Pinto", "Minzhou Pan", "Bo Li"]
year: 2025
venue: "ICLR 2025"
source_id: paper-chen-2025-safewatch
project: safety-classifier-compression
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, method]
status: active
related: [visual-token-pruning]
created: 2026-08-24
updated: 2026-08-24
---

# SafeWatch

## 论文角色

这是当前课题中“**多模态安全 Guard + 自回归归因生成 + 视觉 Token 剪枝**”的直接证据。模型以 InternVL2-8B 为底座，输入视频、查询与可定制安全政策，输出视频描述、多标签违规判定和逐政策解释。

## 方法

1. **Safety-aware event sampling：** 先将视频切分为潜在安全事件，每个事件采一帧，避免均匀采样漏掉短事件或逐帧处理带来冗余。
2. **Parallel Equivalent Policy Encoding（PEPE）：** 将长政策拆成独立 chunk，屏蔽不同政策间的注意力，并赋予等价位置编码，以降低自回归政策编码的顺序偏置和计算量。
3. **Policy-Aware Adaptive Pruning（PAP）：** 计算每个政策 chunk 对每个视频 token 的 cross-attention relevance，再按政策分配预算并保留 Top-k token；删除其余特征并更新 KV cache，之后解码 guardrail flags 与 explanations。
4. **多阶段训练：** 先做多任务 guardrail 训练，再专门训练模型适应 PAP 引入的分布变化，最后用偏好后训练缩短、具体化解释并降低误报。

## 直接结果

- 作者在 SafeWatch-Bench 上报告：剪除最高 90% 视频 token 时，平均性能下降仍小于 1%；随机剪枝会显著损伤同底座 SFT baseline（Figure 5）。
- Table 6 显示，同底座 SFT baseline 的平均时间为 4.6 s，完整 SafeWatch 为 3.9 s，约降低 15%；论文正文同时报告相对同底座 InternVL2-8B 约减少 0.4 s。
- Table 6 也显示不能把 token 比例直接当作系统加速：SFT baseline 与完整 SafeWatch 的 prefill GFLOPs 为 98,245 与 97,430，差异不到 1%；PR-95%/PR-99% 虽将时间降到 3.8/3.7 s，但准确率分别降至 65.3/55.9，解释评分降至 5.33/4.78。
- 完整 SafeWatch 的 guardrail accuracy、GPT-4o explanation rating 与 adaptability 分别为 72.6、7.17、82.7；去掉 PAP 时为 69.9、6.83、79.1。不过完整结果同时包含 PEPE、PAP 与训练阶段，不能把所有质量提升都归因于剪枝。

## 对“归因”的解释边界

论文的 explanation 是自然语言理由，经过 LLM judge 和人评验证质量；PAP 的 token relevance 来自政策—视频 cross-attention。论文没有证明自然语言理由与被保留 token 之间具有因果忠实性，也没有要求输出帧号、区域框或 token provenance。因此它证明了“剪枝后仍可生成高质量解释”，但没有完整证明“解释忠实地归因到未被删除的视觉证据”。

## 局限

- 直接验证集中在视频审核，不等价于图像—文本隐式组合危害、OCR、小目标、隐写或多轮对话。
- PAP 需要专门的 adaptive-pruning training；不能直接假设任意现成 Guard 使用 training-free Top-k 都能维持安全召回。
- 平均 accuracy/F1 与解释评分不足以替代 fixed-FPR recall、worst-group recall、校准、漏报成本和归因忠实度。
- 延迟包含输入、输出长度和实现差异；论文未给出 TTFT-to-verdict、decode tokens/s、P95 或逐阶段 wall-clock 分解。

## 可复现信息

- 正式论文：ICLR 2025 proceedings。
- 官方项目页提供模型、代码、数据与 demo 链接；本库保存正式论文 PDF，未在本次任务中复现实验。

