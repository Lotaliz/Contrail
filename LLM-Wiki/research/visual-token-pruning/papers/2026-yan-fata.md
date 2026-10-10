---
id: note-2026-yan-fata
type: paper-note
title: "Feature-Aware Token Attack for Compression-Triggered Stealthy Failures in Large Vision-Language Models"
authors: [Shilinlu Yan, Bowen Chen, Yuechen Zhang, Zhenhong Zhou, Li Sun, Sen Su]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-39134
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, multimodal-safety]
status: active
created: 2026-10-10
updated: 2026-10-10
---

# FATA：压缩才触发的视觉输入失败

## 原件与阅读范围

用户从候选索引选择本文。精读 [arXiv 2609.39134v1](https://arxiv.org/abs/2609.39134v1)，CC BY 4.0；完整 HTML 原件见 [[LLM-Wiki/raw/papers/2609.39134v1.html]]。核对正文 §3–6、表 1–8，以及附录 A–D/F/G/H 的预算、样本构造、跨架构适配与检测协议。未执行攻击、代码或模型，数字为作者报告；投稿信息不作为录用信息。

PDF 原件另见 [[LLM-Wiki/raw/papers/2609.39134v1.pdf]]（29 页）；完整文件已解析，关键图表与 HTML 数字交叉核查，SHA256 登记在同一 source_id 的 local_artifacts。

## 方法与威胁模型

核心目标是同一对抗图像在 full 路径仍答对，但经过 token 压缩后答错。§3.2 在冻结 CLIP 的 clean 最后一层 CLS→patch attention 上固定 top-64 目标和特征 anchor，优化图像扰动：抑制这些位置的 attention，同时保持对应特征方向的 cosine 相似。两项使用同一固定集合，anchor 停止梯度；随机起点 PGD 仅更新输入，主设置为 $\epsilon=2/255$、步长 $0.5/255$、100 步、语义权重 1。

LLaVA 主实验仅用视觉编码器梯度，优化时不访问压缩器、预算、问题或语言主干，属于灰盒设定。攻击提取的是最后一层特征，而 LLaVA 推理使用倒数第二层特征；不能把目标 anchor 看成最终视觉证据的直接真值。

**关键部署边界：** 图 2D、附录 B.1 的 LLaVA compressed 路径先选/合并 $K$ 个代表，再相似度回填为 576 个槽位送入 projector/LLM。$K$ 是代表数，不是 LLM 实际短序列长度；这是信息压缩的受控重建协议，不能据其准确率表断言常规短序列剪枝的时延或同等攻击效果。

## 条件指标与主证据

§3.3 定义 SR 为攻击 full-token 准确率相对 clean full-token 的保持率，CER 为压缩路径的总错误率，CBR 则仅在 clean-full、attack-full、clean-compressed 三者均正确的交集中统计 attack-compressed 的错误率。CBR 的分母随攻击变化；CER 包含原始任务错误，二者不能互换成“新增失败率”。

§4.1 使用 TextVQA-Open、VQAv2-Open、ScienceQA-MC、VQAv2-MC 各 1,000 张 visually dependent 图像；四个压缩器为 VisionZIP、VisPruner、FlowCut、PruMerge。附录 D 先固定每图代表问题，再保留 LLaVA 对原图正确、黑图错误的前 1,000 项，ScienceQA 合并 train/val/test 仅用于评测。不是随机完整 benchmark，也不是安全 Guard 标签任务。

- 表 2：LLaVA FATA 的 SR 96.3%、CER 30.38%、macro CBR 22.1%；CAA 为 89.8%、24.65%、15.7%。attention-only 与 CAGE 的 CBR 更高，但 full-token 保持率更差；本文支持保持质量与压缩失败的权衡，不支持 FATA 所有指标最强。
- 表 3、附录 F：attention-only 的 SR/CBR 为 66.7/32.9，semantic-only 为 98.5/14.5，联合为 96.3/22.1；联合 CBR 的提升不是每个数据集×压缩器设置均成立。
- 实用预算由 clean 保持率至少 80% 的最小候选预算选择并冻结，主要为 64/576 或 32/576，FlowCut 的 VQAv2-MC 为 64。图 3 的 23.3% 压缩后新增失败使用共同 clean-full-correct 分母，与 CBR 22.1% 不同。

## 跨模型与检测不能外推的部分

附录 G.1 的 Qwen3.5 适配是**白盒且 task-aware**：使用真值答案、下游梯度、具体压缩器和预算，联合压缩 CE 与 full-token CE/clean-logit 保持，各项梯度先分别归一化。其 SR 99.3%、CBR 46.43% 不是 LLaVA 灰盒目标不经修改的黑盒迁移。

附录 G.2 的 InternVL TA-FATA 同样显式使用压缩器的输出差、切点排序、diversity/relation、分层语义保持；优化涉及五种压缩器，正文报告四种。SR 93.94%、CBR 40.38%，且 SR 使用 exact-match，而主准确率表使用 task-credit，不能直接重算或跨模型无条件比较。

§5、表 8：三种检测器在 5% FPR 下 FATA TPR 为 2.4%、13.4%、49.7%，为被比较攻击中最低；但 ML-ATD 的 AUROC/AUPR 并非最低。附录 H.2 的 Feature Squeezing 使用对真值答案的得分变化，检测结果是离线协议证据，不证明无真值线上系统的可部署性或最优防御。黑盒迁移、更广任务和更强检测器仍为作者限制。

## 复现与项目判断

附录 D 说明 archived VQAv2-MC 的原始 option seed/RNG 不可由新 builder 单独重建，需要保存的题目、选项顺序和答案映射；本轮没有检查外部代码或归档包。JPEG/摄像头、政策条件、真实服务时延和安全召回不在已核对实验内。

**本项目判断：** 可复用“clean/perturbed × full/pruned”四路配对和明确条件分母，测 C5 是否出现 full 正确而低预算漏判的压缩特异风险。与 [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-sap.md|SAP]] 相邻，但本文不测试 SAP 修复或政策翻转；与 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]] 的关系是鲁棒性评测。不能将该攻击在重建协议下的 CBR 直接作为 C5 的安全风险数字。

TODO：真实短序列/单局部框协议、同图政策条件、匹配 clean 预算、Unsafe recall/FPR 与原件可复现映射；未由本文直接新增正式动机或 concept。
