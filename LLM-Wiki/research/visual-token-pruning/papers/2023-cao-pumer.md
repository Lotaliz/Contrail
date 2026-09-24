---
id: note-2023-cao-pumer
type: paper-note
title: "PuMer: Pruning and Merging Tokens for Efficient Vision Language Models"
authors: [Qingqing Cao, Bhargavi Paranjape, Hannaneh Hajishirzi]
year: 2023
venue: ACL 2023
source_id: paper-cao-2023-pumer
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, vision-language-model, visual-token-pruning, token-merging, knowledge-distillation, efficient-inference]
status: active
created: 2026-09-18
updated: 2026-09-18
---

# PuMer：图文条件剪枝、同模态合并与训练适应

## 书目信息与精读范围

[ACL 2023 官方页](https://aclanthology.org/2023.acl-long.721/)，DOI `10.18653/v1/2023.acl-long.721`，会议页码 12890–12903；既有 14 页原件 [[LLM-Wiki/raw/papers/2023-cao-pumer.pdf]]，本轮只读复用并核对 SHA256。ACL 官方页明确 2016 年及以后材料为 CC BY 4.0；代码 MIT。

精读正文 §1–8、算法 1、式 (1)、图 1–5、表 1–4、附录 A.1–A.2 表 5–7；责任清单不作为算法证据。视觉核对 PDF 第 4–5、7、12 页，保留表头、脚注与吞吐量 batch 协议。官方代码固定观测版本 `8a00d85314175a4635d074fb003ae39da171ddc7`，来源 `code-pumer-2026-audit`：核对宿主 attention/合并路径、`reducer.py` 二分图函数、任务 KL 蒸馏与配置；未运行训练、模型或 benchmark。登记 deep-read / source-checked，不标 reproduced。

## 任务场景与执行位置

这是**面向图文理解、匹配与分类的 encoder 式 VL 模型压缩**，不是自回归 MLLM 解码加速。对象为 ViLT（110M）和 METER（330M）。任务有四个数据集/任务家族：Flickr30k 双向图文检索、VQAv2、SNLI-VE 视觉蕴含、NLVR2 两图自然语言推理；将检索拆开时是五项测量。即使 VQAv2 数据集含开放式问题，该实现用固定答案类别的 classifier，而不是自由文本生成。

ViLT 用文本 embedding 与线性 patch embedding，拼接后进入 12 层联合 Transformer；METER 先运行 RoBERTa/CLIP 单模态编码器，再进行跨模态融合。ViLT 的 text-to-image attention 是联合 self-attention 的图文子块，METER 使用显式 cross-attention。不能把两者都描述成 LLaVA 式“ViT-projector-LLM”。

PuMer 在多个**跨模态层内部**插入 token reducer，先获得当前层图文交互，再缩短后续 token 流：图文输入 → 一些正常融合层 → TIP → MAM → 后续融合层 → classifier/匹配头。METER 的前置完整 CLIP 视觉编码并未变短；ViLT 本身没有同样的重型独立 ViT，因此减少联合融合层对其总计算的影响更大。

## 方法：图文关联与合并

### Text-Informed Pruning（TIP）

对视觉 token $v$，复用已经计算的 text-to-image attention：

$$
s_v=\frac{1}{|T|}\sum_{t=1}^{|T|}\sum_{h=1}^{H}A^h_{tv}.
$$

按 $s_v$ 保留 top-$K'$，其中 $K'=(1-k)|V|$，$k$ 是删除比例。原文后面有 keep ratio 表述，但算法定义中的 $k$ 是 prune ratio，不应混用。代码对 head 求平均而非求和；head 数固定时只差共同倍率，不改变排序。

TIP **不另建可训练 MLP scorer，不另跑一个图文模型**；额外工作是 attention 聚合、top-k 和 gather。需要先完成本层交互，不是输入图像时就有免费语义分数，也不能省掉已经执行的早层。attention 高低是启发式，不是 token 因果必要性的证明。

### Modality-Aware Merging（MAM）

在 TIP 之后，对保留图像 token 和文本 token **分别合并**，不把图像与文字混成一个 token。相似度 metric 复用当前 self-attention 的 key 表示；把每个模态的 token 按奇偶拆成两组，计算跨组相似度，每个源节点找最佳目的节点，再取 top-$r'$ 连接并用平均聚合。保留未合并项，多对一连接可以一起聚合。这样避开 k-means 的反复迭代或新增 learned pooling。

注意它只合并**剪枝后剩余项**；被 TIP 删除的内容不会被显式回灌到 anchors。平均聚合缓解合并的信息损失，但不能恢复此前已删掉的小证据。

## 图文关联的额外开销：如何处理、没有解决什么

作者策略是利用既有 forward 的 attention 和 keys，避免为评分重新执行大模块；matching、排序、聚合均可并行且无新训练参数。官方宿主代码 `modules_meter.py`、`vit_vilt.py` 确认 mean-head 图文 attention 评分、top-k、调用二分图匹配与 `merge_wavg`；`pruner.py` 被 README 明确列为弃用，不能把其 MLP 分支当作 PuMer。

个人复杂度拆解（由算法推导，不是作者测量）：若视觉、文本长度为 $N,M$，复用 attention 后的聚合约为 $O(HMN)$；匹配仍要额外计算约 $N'^2/4$ 和 $M^2/4$ 个跨组相似度，以及排序、scatter/gather。**复用 K 表示不等于复用已算好的全部相似度，也不等于零 FLOPs/显存开销。**多个 reduction 层会多次执行，但序列逐步变短。

现代 fused attention 的部署风险（个人推断）：如果原宿主不输出完整 attention 权重，强制取出 $A$ 可能引入额外内存或失去原优化。论文没有评测 FlashAttention/SDPA 下的代价，因此不能从 2023 的“already available”推断在当前 Guard 中免费。需单独测正常融合、attention 提取、TIP、MAM、compact 与后续计算。

## 压缩后的性能如何维持

1. **文本条件选择**：同图不同问题可以保留不同图像内容。
2. **先剪少量、再合并冗余**：不用为了同样压缩率删除全部冗余区域；模态分开减少图文表示混淆。
3. **级联而非单次激烈压缩**：较早层先积累表示，再多次温和缩短，权衡早剪效率与早层信息损失。
4. **压缩路径微调 + teacher 蒸馏**：reducer 无参数，但原 VL 模型需要适应新的 token 流；不是免训练 plug-and-play。

论文 §4.3/A.1：先将原预训练模型按任务微调作为完整教师和基线，再训练带 reducer 的模型。baseline 10 epochs，PuMer 最多 20 epochs，early-stopping patience 5，在 4 张 A100 上训练。公开任务代码用输出分布 KL：`F.kl_div(log_softmax(student), log_softmax(teacher), log_target=True)`；VQA 配置 `logits_loss_scale: 1`、`states_loss_scale: 0`。可确认 logit 蒸馏路径，不能把可选 feature MSE 当作默认主方法，也不能仅因 scorer 无参数就说 backbone 冻结。

## 实验与直接证据

表 1：METER VQAv2 77.5→76.8，吞吐 1.82×、峰值显存减少 38%；ViLT VQAv2 69.5→68.9，吞吐 1.76×、显存减少 45%。ViLT SNLI-VE 76.0→75.6，吞吐 2.01×、显存减少 51%。报告 accuracy 是三次训练结果均值；差值为绝对百分点，不是相对百分比。极小表格舍入差不用于精确统计推断。

表 3（ViLT/VQAv2）：完整 69.5/1×；PuMer 68.9/1.76×；无 TIP 69.2/1.52×；无 MAM 69.1/1.46×；无蒸馏 68.6/1.76×。去掉一项 reduction 会同时减少压缩，因此“去掉后更准确”不能理解为该模块无效；蒸馏在相同吞吐点改善 0.3 个百分点，支持训练适应有益，但不是它独自解释全部保持率。

表 4（ViLT/SNLI-VE）：位置 2,3,4、prune/merge/text 各 0.2 时 74.2/2.03×；位置 7,8,9 相同比例时 75.9/1.31×。默认四级 2,4,6,8 与 0.1/0.3/0.2 得到 75.6/2.01×，显示压缩层位本身是关键 trade-off。附录表 6 分任务给定不同设置，不是学会样本级动态预算。

### 计时协议不能省略

§5.4：推理吞吐测试逐步增加 batch 到 OOM，**各模型采用产生最大吞吐的 batch**，单 GPU 跑 30 秒；ViLT 用 GTX 1080 Ti，从 32 以 8 递增；METER 用 A40，从 16 以 8 递增。显存比较才保持相同 batch。这是完整模型执行管线的实测 throughput，但并非固定 batch=1 的请求 latency；可能包含更大可用 batch 的收益。论文没提供 reducer 分项微秒或 batch=1 延迟。

附录表 7 GFLOPs：METER VQAv2 92→64.7（1.42×），ViLT 16→8.7（1.84×）。实测 throughput 与 FLOPs 变化不必等同；表 1 的 1.82× 不能反推 METER 的单请求 FLOPs 下降 45%。

作者脚注观察 15%–20% 训练加速，但蒸馏教师与更长 epoch 上限存在总成本；未提供整个 teacher+student 项目的等精度总训练时间，不独立认定总训练成本下降。

## 局限与项目启发

作者 §8 明确：对 ALBEF/X-VLM 等视觉编码器远重于跨模态层的模型，E2E 收益可能很小；视觉编码器内减 token 留作未来工作。未评测生成式 LLM、短标签 Guard、尾部漏报或攻击输入。

对安全判别的候选启发：理解/分类任务形态更接近 Guard，但 Qwen-VL 的执行结构不是 ViLT/METER，不能直接迁移“已有 cross-attention”。可以借用级联压缩与压缩路径蒸馏，尚需防止恶意文本把重要图像证据引导成“不相关”。需按固定 FNR 约束而非平均 accuracy 选择预算。完整塔/多层融合若已付费，可能无法满足本项目浅层安全充分前缀目标。

关联：[[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-cdpruner.md|CDPruner]]；[[LLM-Wiki/research/visual-token-pruning/pumer-cdpruner-text-conditioning-cost.md|两篇关联开销与性能机制比较]]；[[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|净收益与执行位置]]。不创建单篇方法 concept，不修改正式 Motivation/研究缺口/实验结果。

## 证据定位与待验证

- 模型、任务与执行位置：§3、§5.1–5.2，图 2–3，PDF 第 3–6 页。
- TIP/MAM：§4.1–4.2、算法 1、式 (1)，第 4–5 页。
- 微调和蒸馏：§4.3、A.1，第 5–6、12 页；代码 `task_base.py`/`conf/task/vqa2.yaml`。
- 吞吐/显存协议：§5.4、表 1，第 6–7 页；组件与层位表 3–4，第 8–9 页。
- 默认配置/FLOPs：表 5–7，第 12 页；限制 §8，第 9 页。
- TODO：batch=1 selector-inclusive 延迟；fused attention 提取代价；教师总成本；Guard 政策覆盖、对象关系及文本诱导下的小证据漏报。
