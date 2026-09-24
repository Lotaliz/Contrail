---
id: note-2025-zhang-cdpruner
type: paper-note
title: "Beyond Attention or Similarity: Maximizing Conditional Diversity for Token Pruning in MLLMs"
authors: [Qizhe Zhang, Mengzhen Liu, Lichen Li, Ming Lu, Yuan Zhang, Junwen Pan, Qi She, Shanghang Zhang]
year: 2025
venue: NeurIPS 2025
source_id: paper-zhang-2025-cdpruner
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, vision-language-model, visual-token-pruning, training-free, efficient-inference]
status: active
created: 2026-09-18
updated: 2026-09-18
---

# CDPruner：条件多样性子集选择

## 书目信息与阅读边界

正式身份已由 [NeurIPS 2025 Main Conference proceedings](https://proceedings.neurips.cc/paper_files/paper/2025/hash/2433fec2144ccf5fea1c9c5ebdbc3924-Abstract-Conference.html) 核实；DOI `10.52202/085713-0855`。31 页官方原件：[[LLM-Wiki/raw/papers/2025-zhang-cdpruner-neurips.pdf]]。对应 arXiv ID 2506.10967；本轮采用会议定稿，不推定 arXiv 当前版本。官方代码链接见原文，未运行。

首次定向阅读为 skimmed。2026-09-18 应用户要求升级为 deep-read / source-checked：核对正文 §1–5、图 1–4、表 1–6、附录 A–F、算法 1、表 7–11、额外可视化及 checklist 的相关声明；重点审查表示获取、DPP 增量计算、计时条件与性能消融。视觉核对 PDF 第 4–5、9–10、23 页。未运行模型、不标 reproduced，也未独立证明近似比保证。

新增有限实现审查：`code-cdpruner-2026-audit` 固定公开版本 `9541616c40fcd5625de1cdb8ea6c33c129eb7864`；只读查看 README、LLaVA 的 `clip_encoder.py`、`llava_arch.py` 和 `model_vqa_loader.py`，没有完整审查 Qwen/InternVL/video adapters。代码与原文的不一致另列，不假定当前发布代码就是论文实验时的版本。

## 研究问题

作者指出两类剪枝的互补失败：attention/重要性排序容易留下重复 token；仅基于视觉相似性去冗余则忽略当前问题，同图不同问题仍选同一集合。CDPruner（Conditional Diversity Pruner）希望同时保留相关信息和全局多样性，减少生成式 MLLM 的视觉前缀长度，不额外训练模型。

## 核心方法

给定 $N$ 个视觉特征 $h_i$、问题表示 $q$ 和外部固定预算 $K$：

1. 建立视觉 token 的 cosine Gram 核 $L_{ij}=\cos(h_i,h_j)$。
2. 计算 token 与指令的 cosine relevance $r_i$，min-max 归一化为 $\tilde r_i\in[0,1]$。
3. 构造条件核 $\tilde L=\operatorname{diag}(\tilde r)L\operatorname{diag}(\tilde r)$，以 DPP 的固定基数 MAP 目标选择集合：

$$
S^*=\arg\max_{|S|=K}\det(\tilde L_S).
$$

对非奇异、正相关权重的集合，其等价分解为：

$$
\log\det(\tilde L_S)=2\sum_{i\in S}\log\tilde r_i+\log\det(L_S).
$$

第一项奖励指令相关性，第二项奖励集合的非冗余性。行列式可理解为所选特征张成的体积平方；近重复向量降低体积。它不是简单 relevant-top-K、max-min 最远点选择或每个 token 的独立阈值。式中的最优目标并不意味着实际求出全局最优：DPP MAP 为 NP-hard，作者采用贪心与 Cholesky 增量更新，报告选择复杂度 $O(NK^2)$。本轮不独立背书其引言中的近似比保证；需核对约束和单调性条件。

表示对齐具有主干差异：有 CLIP 等成对视觉/文本编码器时用对齐编码特征；只有视觉编码器时用 projector 输出和 LLM 的平均指令 token embedding。后者 cosine 的语义有效性依赖跨模态对齐，不等于显式安全证据评分。

执行位置：完整 vision encoder → projector → **选择并压缩视觉序列** → 与文本拼接 → 原 LLM（图 2）。评分可使用编码器侧表示，但实际减少的是 LLM 输入视觉 token；不在 ViT 早层缩短序列、不训练主干、不需要提案 LLM或真实 attention map。完整视觉塔成本仍然存在；选择器也有成本，不能把 training-free 解释为零开销。

## 实验设置、结果与边界

主实验覆盖 LLaVA-1.5-7B、LLaVA-NeXT-7B、LLaVA-Video-7B、Qwen2.5-VL-7B，以及图像问答、视频和 MMDU 多轮对话。主要基线包括 FastV、PyramidDrop、SparseVLM、PruMerge+、TRIM、VisionZip、DART、DivPrune。

作者结果：LLaVA-1.5 将 576 个 token 减为 32，十项任务 Acc 为 60.0，Rel 为 94.3%；NeXT 2,880→160，Rel 为 96.0%（表 1–2）。这些是聚合质量，不是每个任务无损。Qwen 原文 1,296→128，TextVQA 77.8、ChartQA 59.2、AI2D 74.0、Rel 85.2%；完整模型相应为 84.8、86.1、80.4（表 4）。

效率表 6 使用 A100-80GB、NeXT、POPE 的短回答设置：2,880→320，FLOPs 41.7T→4.2T，prefill 246→38、decode 29→22（表头 ms/token），KV 1,440→160MB，POPE F1 86.8→87.2。不能与 AutoPrune 的 RTX 3090 毫秒数跨硬件直接比较，也不能视为所有回答长度下的 E2E 加速。作者报告选择器单样本少于 10ms，不等于目标 Guard 的 selector-inclusive 实测。

图 4 将 DivPrune、无指令条件的 DPPruner 和 CDPruner 对比，支持全局多样性与指令条件分别有益。泛化能力很大程度依赖相关性表示与任务；泛泛提问难以定位特定风险证据，多轮问题改变后也需验证保留内容是否充足。

## 图文关联的额外开销与具体降开销方式

不能把所有成本都归到 $O(NK^2)$：这是已知核矩阵后的 greedy MAP 更新复杂度。在一个含 $N$ token、维度 $D$ 的选择组内，完整成本还包括文本表示、图文 cosine $O(ND)$、视觉 Gram 核构建 $O(N^2D)$，以及约 $O(N^2+NK)$ 的核/Cholesky 状态存储。复杂度拆分是个人算法推导，不是作者分项测量。没有付完完整 LLM forward 后才剪，仍可省其后续全部视觉前缀计算。

### 表示成本随主干不同

- **LLaVA/CLIP 路径**：复用现有视觉塔，但原生 LLaVA 不必运行 CLIP 文本塔；为对齐的 query feature 增加对应文本 encoder、tokenizer、视觉投影及其显存。当前代码 `load_text_tower` 加载 `CLIPTextModelWithProjection`，并接入 CLIP visual projection。因此“model-agnostic / training-free”不等于完全不增加模块或参数驻留，只是这些预训练模块不再训练。
- **Qwen/InternVL 论文路径**：用 projector 输出与 LLM 平均 instruction input embedding，无须额外完整 LLM 文本 forward。代价主要是已有 embedding lookup、均值与 cosine；但均值不是 contextualized 跨模态理解，语义关联质量依赖表示对齐。对应 adapter 本轮未审查。

### 公开 LLaVA 实现的并行与分组

`clip_encoder.py:forward` 创建 image/text 两个 CUDA stream，图像编码与文本编码并行，之后同步，再进行视觉投影。可以隐藏一部分文本塔 wall-clock，但 GPU 资源竞争、额外显存与同步仍在；不等于文本塔免费，也没有本轮实测其隐藏比例。长文本按 CLIP 最大位置数拆段，额外编码和分数归约可能增长。

`llava_arch.py:encode_images` 先对完整 image features 做原 projector，再构建 FP32 $B\times N\times N$ cosine 核；在 $K$ 轮中用矩阵/张量运算更新 `cis` 与 `di2s`，避免每个候选子集重新算 determinant。结果按原索引排序，生成 mask 并真实缩短 LLM 前缀；不是在完整长度上只改 attention mask。

NeXT 公开路径按 image crop 编入 batch，每 crop 输出固定 `visual_token_num`；README 明确 32×5=160 的用法。这限制了单组核的尺寸，但不提供跨 crop 的自由共享配额。视频论文用每帧保留数报告结果；本轮不独立证明其 native implementation 的分组细节。不能无条件把 NeXT 实际选择开销估算为整个 2,880-token 的一次全局 DPP。

作者 §3.4、附录 A 报告并行 greedy solver 单样本少于 10ms；该陈述位于 DPP 求解部分，不明确包含文本编码、核构建、CPU tokenizer、同步和 token 重组。因此不能解读为整个 text-guided pruning pipeline 的额外耗时小于 10ms。sliding-window / Markov chain 在引言作为可能近似提及，不作为主实验已使用的事实。

## 性能保护、消融与失败条件复核

本方法**不靠微调、teacher 输出蒸馏或被删 token 回灌**维持性能，而靠预训练表示、问题条件和集合多样性选择。原文式 (1) 的完整/剪枝输出差异是理想目标，并没有在 runtime 逐候选运行完整模型、求输出误差或训练该 loss。实际用 DPP proxy；不能把式 (1) 误读为双路推理开销。

图 4：DivPrune → 无指令条件的 DPPruner → CDPruner，支持 DPP 全局多样性和相关性条件分别有益。相关性不足的泛泛提问依然难定位小证据。主表 1 的 LLaVA / 32：TextVQA 58.2→53.2、MM-Vet 31.3→27.8，聚合 Rel 94.3% 不保证任何单项无损。Qwen / 128 的 ChartQA 86.1→59.2、OCRBench 863→632；较新主干已在 projector 中压缩，进一步删 token 损失更大（附录 E 的作者解释，不是独立验证）。

附录 C.4 可选 balance factor 不是主表默认：$\alpha=\theta/[2(1-\theta)]$，构造 $\widetilde L'=\operatorname{diag}(e^{\alpha\tilde r})L\operatorname{diag}(e^{\alpha\tilde r})$，从而使目标与 $\theta\sum_i\tilde r_i+(1-\theta)\log\det L_S$ 成正比。它改变了 relevance 权重函数，不只是给式 (8) 直接乘一个系数。表 11 / 64-token 的最佳 $\theta$ 随任务变化，逐任务 best 的 Rel 97.5% 是调优/选优汇总，不能当作一个无调参部署策略的保持率。默认没有该额外因子，但预算仍外部指定。

多轮 MMDU 表 5：100 样本、五轮、至多 12 张图、GPT-4o 六维评分，32 token 的 Rel 96.7%。它支持相对只看 relevance 的 TRIM，多样性对未来问题有益；不保证任意未来问题都能由一次剪枝前缀回答，更不是安全政策完备性证明。

效率 §4.7 / 表 6 使用 A100-80GB、POPE 短回答，一次 prefill 与一次 decode；公开评测 loader 显式 `batch_size == 1`，但不能仅凭 loader 推定论文所有计时脚本的 batch、warmup、重复次数或视觉编码计时边界。还需 selector-inclusive E2E/TTFT 与分项计时。Checklist 以“免训练”解释无需统计显著性；这不能替代 latency variability 或主结果不确定性报告。

## 当前公开代码与原文的相关性符号不一致

直接证据：固定 revision 的 `llava/model/llava_arch.py` 第 158 行计算正 cosine 矩阵，第 **159 行**为 `relevance = (-relevance).mean(dim=-1)`，之后 min-max 归一化；原文式 (5)–(6) 使用正 cosine。`model_vqa_loader.py` 将问题文本直接传给 `texts`，仅去掉回答格式后缀，没有发现把文本转换为否定问题的逻辑。

在单文本 embedding 的情况下，取负再 min-max 会反转相关性的排序，与论文“越相关权重越高”的方向不一致。该观测是静态代码审查，不是模型实验；不能确认作者报道结果使用了这个 revision，也不据此断言原文成绩无效。若复现或将其作为 Guard baseline，应先向作者核对，并将论文一致版本与 release-as-is 分开记录；本轮没有修改官方代码或暗中修复。

## 与 AutoPrune 的关系及新发现

[[LLM-Wiki/research/visual-token-pruning/papers/2026-liu-autoprune-ai4ai.md|AutoPrune]] 主实验将本方法作为强人工先验：先保留 CDPruner 集合，再在受限 TPDSL 空间中搜索评分、交换与重组；源预算 32 最多交换两个成员，并有可选残差信息回灌。DPP 和指令条件不是 AutoPrune 从零发明。

基线保真度待核：AutoPrune 表 3 的自行复现 CDPruner，在同名 Qwen2.5-VL-7B / 128-token 设置下 TextVQA 仅 23.24、ChartQA 32.68、AI2D 66.26；与本论文表 4 的 77.8、59.2、74.0 差异明显。两篇对应完整模型的这三项分数一致。**这是跨论文协议/实现差异的诊断线索，不是证明 AutoPrune 实际不如 CDPruner**；需要统一 checkpoint、图像预处理、prompt、split、位置编码与评分表示后再比较。没有统一复现，不能据此确认其对原生 Qwen CDPruner 的超越。

## 对当前研究的候选启发

个人判断：相关性 × 多样性是值得保留的强基线，也提示安全证据集合不能仅按单项显著性排序。安全判断还依赖对象关系、局部小证据和政策覆盖，cosine/DPP 不是证据充分性或漏报保证。可候选性地把指令换为政策条件并加入证据覆盖约束，但需要开发/测试集隔离以及尾部类别漏报评测；不能直接宣称有效。

关联：[[LLM-Wiki/concepts/methods/multimodal-token-pruning.md|执行位置与净收益]]；[[LLM-Wiki/research/visual-token-pruning/papers/2023-cao-pumer.md|PuMer]]；[[LLM-Wiki/research/visual-token-pruning/pumer-cdpruner-text-conditioning-cost.md|关联开销与性能机制比较]]；[[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stacktok.md|StackTok]]；[[LLM-Wiki/research/visual-token-pruning/overview.md|项目主线]]。本轮不新建方法缩写标签、单篇概念或正式研究缺口。

## 证据定位与待验证

- 执行位置与表示：图 2、§3.1–3.3，PDF 第 4–5 页。
- 条件 DPP：§3.2–3.4、式 (3)–(8)，第 4–6 页。
- 主要质量结果：表 1–4，第 6–9 页；多轮结果表 5，第 9 页。
- 效率、组件归因：§4.7–4.8、表 6、图 4，第 10 页。
- DPP 增量计算：附录 A、算法 1、式 (9)–(17)，第 16–17 页；balance factor 表 11、式 (18)–(19)，第 22–23 页。
- 代码精确定位：固定 revision 下 `clip_encoder.py` 的 `load_text_tower`/`forward`；`llava_arch.py:141` 起的 `encode_images`，相关性符号第 159 行；`model_vqa_loader.py` 的问题传递与 batch assert。
- TODO：相关性正负号及论文实验时 revision；原生 Qwen adapter 与 AutoPrune 重实现差异；DPP 数值退化与理论条件；selector-inclusive Guard 计时；政策相关性是否漏掉尾部风险证据。
