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
tags: [paper-note, research, method, safety-guardrail, multimodal-safety, visual-token-pruning, policy-enforcement, efficient-inference]
status: active
related: [visual-token-pruning]
created: 2026-08-24
updated: 2026-08-31
---

# SafeWatch

## 论文角色

这是当前课题中“**多模态安全 Guard + 自回归归因生成 + 视觉 Token 剪枝**”的直接证据。模型以 InternVL2-8B 为底座，输入视频、查询与可定制安全政策，输出视频描述、多标签违规判定和逐政策解释。

## 问题场景与系统约束

- **用户输入：** 原始视频、由自然语言定义的多个可定制安全政策 chunk，以及审核 query。政策不仅列出禁止项，还可包含允许项和示例（Figure 3、Appendix B.10）。
- **输出：** 结构化三段式响应：安全相关视频描述、每条政策的二值 flag、多标签逐政策解释；这比纯二分类 guard 多了长输入政策与自回归解释成本（§3.1，p. 4）。
- **任务特点：** 危险信号可能只在短事件中出现，类别可重叠，平台政策会改变，还要处理 hard-benign 以控制误报。SafeWatch-Bench 覆盖 Sexual、Abuse、Violence、Misinformation、Illegal、Extremism 六类、30 余细分场景，并同时包含现实视频和生成视频（§4.1，p. 7）。
- **系统特点：** InternVL2 每帧 256 token；均匀稀疏采样可能漏危险，逐帧 guard 又延迟过高。模型必须同时削减视频 token、长政策编码和解释生成成本，因此 SafeWatch 不是一个孤立的 token selector，而是采样、PEPE、PAP 与专门训练的整体系统（§1、§3，pp. 1–6）。

## 方法

1. **Safety-aware event sampling：** 先将视频切分为潜在安全事件，每个事件采一帧，避免均匀采样漏掉短事件或逐帧处理带来冗余。
2. **Parallel Equivalent Policy Encoding（PEPE）：** 将长政策拆成独立 chunk，屏蔽不同政策间的注意力，并赋予等价位置编码，以降低自回归政策编码的顺序偏置和计算量。
3. **Policy-Aware Adaptive Pruning（PAP）：** 计算每个政策 chunk 对每个视频 token 的 cross-attention relevance，再按政策分配预算并保留 Top-k token；删除其余特征并更新 KV cache，之后解码 guardrail flags 与 explanations。
4. **多阶段训练：** 先做多任务 guardrail 训练，再专门训练模型适应 PAP 引入的分布变化，最后用偏好后训练缩短、具体化解释并降低误报。

PAP 对每个政策 query 与每个视频 key 计算归一化 cross-attention，再以视频维均值得到政策级 relevance，并为各政策保留相应 Top-k 视觉 token；剪后 KV cache 直接更新。该机制是“政策条件化 + 多政策联合覆盖”，而不是按单一用户问题只保留一个区域（Equations 5–7、Algorithm 1，p. 6）。

## 直接结果

- 作者在 SafeWatch-Bench 上报告：剪除最高 90% 视频 token 时，平均性能下降仍小于 1%；随机剪枝会显著损伤同底座 SFT baseline（Figure 5）。
- Table 6 显示，同底座 SFT baseline 的平均时间为 4.6 s，完整 SafeWatch 为 3.9 s，约降低 15%；论文正文同时报告相对同底座 InternVL2-8B 约减少 0.4 s。
- Table 6 也显示不能把 token 比例直接当作系统加速：SFT baseline 与完整 SafeWatch 的 prefill GFLOPs 为 98,245 与 97,430，差异不到 1%；PR-95%/PR-99% 虽将时间降到 3.8/3.7 s，但准确率分别降至 65.3/55.9，解释评分降至 5.33/4.78。
- 完整 SafeWatch 的 guardrail accuracy、GPT-4o explanation rating 与 adaptability 分别为 72.6、7.17、82.7；去掉 PAP 时为 69.9、6.83、79.1。不过完整结果同时包含 PEPE、PAP 与训练阶段，不能把所有质量提升都归因于剪枝。
- SafeWatch-Bench-Real 上，模型平均 accuracy/F1/AUPRC 为 72.6/86.7/98.8，GPT-4o 与人评解释分为 7.17/8.21，单视频 3.9s；同底座 InternVL2-8B 为 29.1/41.1/80.1、5.07/4.41、4.3s（Table 1，p. 8）。
- GenAI 子集平均 accuracy 为 72.0，GPT-4o 为 44.8；五个外部数据集 LSPD/XD-V/UCF/FakeSV/FVC 分别为 93.8/93.8/96.4/71.9/79.8（Tables 2–3，p. 8）。这些结果混合了 2M 数据集、架构与训练收益，不能作为 PAP 单模块的因果效果。
- 三个未见政策 children/firearms/accidents 为 81.8/87.8/78.5；随机重排政策、定制白名单、仅标签、QA 四种 prompting 任务平均 accuracy 为 64.7/64.5/91.4/80.8（Tables 4–5，p. 9）。
- 训练阶段消融从 Stage-1 的 63.9/5.84/69.7，经过 Stage-2 67.3/6.12/74.9，到 Stage-3 72.6/7.17/78.0（accuracy/explanation/adaptability），证明安全质量依赖 pruning-aware training 与偏好后训练，而非把通用模型直接接 Top-k（Table 8，p. 16）。

## 对“归因”的解释边界

论文的 explanation 是自然语言理由，经过 LLM judge 和人评验证质量；PAP 的 token relevance 来自政策—视频 cross-attention。论文没有证明自然语言理由与被保留 token 之间具有因果忠实性，也没有要求输出帧号、区域框或 token provenance。因此它证明了“剪枝后仍可生成高质量解释”，但没有完整证明“解释忠实地归因到未被删除的视觉证据”。

## 局限

- 直接验证集中在视频审核，不等价于图像—文本隐式组合危害、OCR、小目标、隐写或多轮对话。
- PAP 需要专门的 adaptive-pruning training；不能直接假设任意现成 Guard 使用 training-free Top-k 都能维持安全召回。
- 平均 accuracy/F1 与解释评分不足以替代 fixed-FPR recall、worst-group recall、校准、漏报成本和归因忠实度。
- 延迟包含输入、输出长度和实现差异；论文未给出 TTFT-to-verdict、decode tokens/s、P95 或逐阶段 wall-clock 分解。
- PR-20/40/95/99 是全局实验点，未报告每类风险的最坏漏报曲线；“剪 90% 仅降 1%”仍是平均 accuracy 结论，不能推出高危类别在 fixed FPR 下安全。
- 事件分割器若漏掉极短、渐变或跨事件危害，后续 PAP 无法恢复；论文也未以定位框、时间戳或因果遮挡验证解释忠实度。

## 可复现信息

- 正式论文：ICLR 2025 proceedings。
- 官方项目页提供模型、代码、数据与 demo 链接；本库保存正式论文 PDF，未在本次任务中复现实验。
