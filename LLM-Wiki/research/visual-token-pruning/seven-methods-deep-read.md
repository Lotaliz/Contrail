---
id: visual-token-pruning-seven-methods-deep-read
type: synthesis
title: 七种多模态 Token 剪枝方法精读：TRIPS、PuMer、FastV、SparseVLM、VisionZip、DivPrune 与 SafeWatch
tags: [research, method, visual-token-pruning, vision-language-model, multimodal-safety]
project_id: visual-token-pruning
sources: [paper-jiang-2022-trips, paper-cao-2023-pumer, paper-chen-2024-fastv, paper-zhang-2025-sparsevlm, paper-yang-2025-visionzip, paper-alvar-2025-divprune, paper-chen-2025-safewatch]
status: active
created: 2026-08-31
updated: 2026-08-31
synthesis_kind: literature-review
---

# 七种多模态 Token 剪枝方法精读

## 结论先行

七篇论文并不是在解决同一个场景里的同一种 token 冗余：

1. **TRIPS、PuMer** 面向编码器式图文理解，文本在视觉/跨模态编码前已知，适合单轮检索、VQA、蕴含或分类；目标主要是减少视觉塔或 cross-modal encoder 成本。
2. **FastV、SparseVLM** 面向 decoder-only LVLM，在 LLM 浅层或多层内依据当前 prompt 的 attention 动态剪视觉 token；它们能利用问题相关性，但已支付视觉塔与部分 prefill 成本，而且保留集不天然适合下一轮问题。
3. **VisionZip、DivPrune** 在视觉 token 进入 LLM 前做文本无关压缩：前者保留视觉编码器的信息聚合点并合并上下文，后者最大化保留集多样性。它们更利于 multi-turn 与 KV cache 复用，但可能错过当前任务的稀有局部证据。
4. **SafeWatch** 是七篇中唯一直接面向多模态安全判别的工作。它不是把通用剪枝器直接套到视频，而是把安全事件采样、并行等价政策编码、政策条件化视觉剪枝和三阶段训练联合设计；因此其质量与效率不能归因于 PAP 剪枝单模块。
5. 对多模态安全 Guard，最有根据的设计不是只选“相关性”或只选“多样性”，而是把 **政策相关性、时空/语义覆盖、被删信息摘要、风险自适应预算和安全回退** 同时纳入，并用逐风险 recall、fixed-FPR、worst-group 与真实 time-to-verdict 验证。

## 场景总览

| 方法 | 用户输入与输出 | 任务特点 | 系统位置 | 主要选择信号 | 训练需求 |
|---|---|---|---|---|---|
| TRIPS | 图像+问题/陈述/caption；答案、二分类或检索分数 | 单轮，文本先验已知；同图因问题而异 | ViT 第 5/10 层内 | 文本 `[CLS]` 对视觉 patch 的相关性 | 端到端预训练与下游微调 |
| PuMer | 图像+短文本；检索、VQA、视觉蕴含、NLVR2 | 视觉 token 远多于文本；融合层是主要成本 | 多个 cross-modal layer | text-to-image attention + 模态内相似性 | 下游微调+蒸馏 |
| FastV | 图像/视频+system/user prompt；自回归回答 | 视觉前缀很长；深层视觉 attention 低 | LLM 单一过滤层后 | token received attention | 免训练 |
| SparseVLM | 图像/视频+问题；自回归回答 | 问题相关区域变化；模板词不应等权评分 | LLM 多层渐进 | text raters、跨模态 attention rank、回收 | 免训练 |
| VisionZip | 图像/视频+单轮或多轮问题；自回归回答 | 视觉编码器产生 proxy token；需跨轮复用 | 视觉塔后、LLM 前 | 视觉 attention dominant + key 相似性合并 | 免训练；可选 projector 微调 |
| DivPrune | 图像/8帧视频+问题；caption/QA | 极端压缩时 importance selector 保留集合重复 | 视觉塔后、LLM layer 0 前 | max-min embedding diversity | 免训练、免校准 |
| SafeWatch | 视频+多条自然语言政策+审核 query；描述、多标签 flag、解释 | 危害短暂、类别重叠、政策可变、漏报/误报不对称 | 事件采样后；MLLM 内按政策剪 | policy-video cross-attention | 三阶段专门训练 |

## 1. TRIPS：问题已知时，在视觉主干内部早剪

### 问题场景

TRIPS 使用 ALBEF 式双流 VLP。用户输入可以是图像加自然语言问题、图像对加陈述，或图像—caption 检索对；输出分别是生成式 VQA 答案、NLVR2 二分类或检索相似度。此时文本在视觉编码完成前已经给定，而且问题本身决定应看哪里。论文以同一图像中“背景的树/雪”等区域说明，vision-only CLS 排名无法表达 query dependence（§1，pp. 4084–4085）。

系统由 ViT、BERT 和 6 层跨模态融合器组成。长 patch 序列既增加 ViT 自注意力，也增加之后的融合成本；它没有 decoder-only LVLM 的自回归 decode、KV cache 或 multi-turn 问题。

### 方法

TRIPS 在 ViT 第 5、10 层插入 text-guided patch-selection。文本 `[CLS]` 经共享 query 投影后为视觉 token 打分，每次保留 70% Top-k；低分 token 不全部丢弃，而是加权融合为一个 inattentive token。该方法不增加参数，但文本必须提前进入视觉主干，架构耦合较强（§3.2，pp. 4087–4088）。

### 实验效果

- 任务：VQAv2、NLVR2、COCO/Flickr30K 双向检索。
- 训练：CLIP ViT-B/16、BERT-base，4M unique images/5.1M pairs，30 epochs、8×V100（§4）。
- 代表效率点：20.89G FLOPs、343.05 image-text pairs/s、11ms；对照 ALBEF-C 为 36.63G、197.52/s、21ms（Table 3）。
- 同为 384 分辨率，TRIPS 为 55.60G、115.01 pairs/s、VQA 76.23、NLVR2 82.35；未剪模型为 76.03G、79.32 pairs/s、76.12/82.35。把预算用于 456 分辨率后，在 74.83G 下得到 76.54/83.02（Tables 5–6）。
- 去掉低分 token 融合或文本相关注意力，VQA 从 76.23 降至 75.92/75.23（Table 7）。

### 边界

论文只验证固定 keep rate、单轮文本条件和编码器式 VLP。它支持“安全政策可用于视觉选择”，但没有视频事件、解释生成、未来轮次复用或风险自适应预算证据。

## 2. PuMer：融合层里联合剪视觉、合并图文

### 问题场景

PuMer 面向 ViLT-110M 与 METER-330M。图像常产生 576 个 patch，而文本往往只有十几个 token；用户输入是图像加 caption、问题或陈述，任务覆盖 Flickr30K 检索、VQAv2、SNLI-VE 与 NLVR2。其瓶颈是 cross-modal encoder 反复处理不平衡的长序列，而不是长答案生成（§1、§3）。

### 方法

每个无参数 reducer 含两步：

1. Token Importance Pruning 复用 text-to-image cross-attention，跨头和文本 token 平均后删低分视觉 token；
2. Modality-Aware Merging 在图像内部、文本内部各自做二分软匹配与平均合并，避免跨模态 embedding 混合。

多个 reducer 分布在 cross-modal layers 中形成渐进压缩，再用原 fine-tuned 模型做知识蒸馏（§4.1–§4.3，pp. 12893–12894）。

### 实验效果

- METER：1.79–2.07× throughput、峰值显存下降 38%–43%，任务性能下降 0.5–0.9 点；ViLT：1.74–2.01×、显存下降 45%–51%、下降 0.4–0.7 点（Table 1）。
- METER/VQAv2：原 384 输入为 77.5；PuMer-384 为 76.8、1.82×；降到 320 为 77.0、1.62×；PuMer-320 为 76.3、2.86×（Table 2）。
- reducer 放在 2/3/4 层可到 2.03×但损失 1.8 点，放在 7/8/9 层仅 1.31×但损失 0.1 点；2/4/6/8 渐进配置为 2.01×、损失 0.4 点（Table 4）。

### 边界

作者明确指出，当视觉塔才是主要成本、cross-modal encoder 较轻时，收益有限（§8）。吞吐还分别在 GTX 1080 Ti 和 A40 上按最大 batch 测量，不能与 decoder-only 论文的 batch=1 latency 横比。

## 3. FastV：浅层先读图，第二层后删一半

### 问题场景

FastV 面向 LLaVA/QwenVL/Video-LLaVA 式生成模型：用户给图像或视频、system prompt 与问题，模型自回归输出 caption、短答案或开放式回复。LLaVA-1.5 的单图有 576 token，高分辨率可达 2304，Video-LLaVA 有 2048；视觉 token 约占输入 64%，但论文观察到深层收到的 attention 很低（§1、§3）。

### 方法

在过滤层 $K$ 统计各视觉 token 从其余 token 接收到的平均 attention，删最低的 $R\%$，后续 MHA 与 FFN 不再处理。默认 $K=2$、$R=50\%$。方法免训练、易插入，但前两层 LLM、视觉塔和 projector 已经完整执行（§4）。

### 实验效果

- LLaVA-1.5-7B：99.3→54.6B FLOPs，四任务均分 69.8→69.7；13B：154.6→84.6B，73.6→73.6；Qwen-VL-Chat：71.9→39.5B，69.7→69.2（Table 1）。
- 覆盖 NoCaps/Flickr caption、A-OKVQA/MMMU、OCR-VQA、MME/MM-Vet/SEED 与视频 QA；50% 通常稳定，75%/90% 更易伤 caption 和细粒度任务。
- A40、A-OKVQA 的 Table 4 真实计时实际使用 layer 0 随机删 50%：7B 0.344→0.230s、19→16GB、76.7→75.3；13B 0.539→0.341s、38→30GB、82.0→80.5。因此该 latency 点不能被当作标准 attention selector 的完全配对证据。

### 边界

后续独立研究发现 FastV 有空间位置偏置，在高压缩和 RefCOCO 上可能弱于 random/pooling。它仍是最重要的 decoder 内 training-free 基线，但不能从平均 benchmark 推出安全证据没有被删；当前 query 决定的保留集也不适合无损复用到下一轮。

## 4. SparseVLM：只让视觉相关文本评分，并按层自适应回收

### 问题场景

SparseVLM 处理单图或视频问答。论文强调两层条件性：同一图像的问题不同，相关 patch 不同；同一问题中又只有“Tylenol、ibuprofen、fridge”等词真正与视觉相关，介词与模板词不应等权成为 rater（Figure 3，p. 5）。

### 方法

进入 LLM 前先用视觉—文本 embedding 相似度选出高于均值的 text raters。每个 decoder layer 复用 rater-query 到 visual-key 的 attention 子矩阵 $P$：行均值给 token 排序，$L_v-\operatorname{rank}(P)$ 估计冗余并决定删除量。删除池中较重要的一部分通过 density-peak 聚类与簇内求和重构为少量 recycled tokens（§3.2–§3.3，pp. 3–5）。

### 实验效果

- 图像任务：GQA、MMBench、MME、POPE、ScienceQA、SEED、TextVQA、MM-Vet；模型：LLaVA、Mini-Gemini、Qwen2-VL。
- LLaVA 576→192：综合相对性能 99.1%，4.62→2.14T FLOPs，57.82→36.50ms；576→128：96.7%、1.72T、33.28ms（Table 1，A100-80GB）。
- 576→64 时 SparseVLM 为 89.3%，FastV 为 72.0%；但 POPE、MM-Vet 等单任务仍有明显下降，平均值不能代表每类能力。
- Video-LLaVA 2048→194：四项视频 QA 综合相对 accuracy 95.0%，FastV 80.3%（Table 3）。
- 回收在 64 token 时将 POPE 72.8→77.5；text rater 在 POPE 上比使用全部文本高 2.7 点（Table 4、Figure 5）。

### 边界

attention 获取/重算与聚类有真实 kernel 开销；方法的“自适应”只由矩阵秩决定，不含安全风险与校准。被删 token 不能在下一轮自然恢复，视频测试也没有短暂危险事件或政策变化。

## 5. VisionZip：先保视觉编码器的信息代理，再给 LLM 一个短前缀

### 问题场景

VisionZip 关注视觉塔输出的结构性冗余和真实多轮部署。LLaVA-NeXT 一张图可达 2880 token；多轮对话会把视觉前缀写入 KV cache，若上一轮按问题剪图，下一轮换问题时 cache 可能缺证据（§1、§4.3）。

### 方法

在视觉塔的第二末层，CLIP 用 `[CLS]` attention 选 dominant tokens，SigLIP 用平均 received attention；剩余 token 以 key 相似性合并成 contextual tokens。压缩发生在 LLM 前，免训练；可选仅用 1/10 LLaVA 数据微调 projector 约 30 分钟（§2.3–§2.4）。

### 实验效果

- LLaVA-1.5 的 576→192/128/64：免训练综合相对性能 98.5%/97.6%/94.0%，projector 微调后 99.1%/98.4%/95.2%（11 benchmarks，Table 1）。
- LLaVA-NeXT 的 2880→640/320/160：免训练 97.6%/95.0%/92.0%，微调后 98.9%/97.9%/95.5%（Table 2）。
- 2880→160 时 POPE 总时间 2293→756s（3.0×），prefill 218→27.8ms（7.8×，A800，Table 4）。
- Video-LLaVA 2048→136 时四项平均相对性能 93.2%，SparseVLM 86.5%、FastV 52.1%（Table 3）。
- TextVQA 干预：先删视觉塔最高 attention 的 50 token，再让 SparseVLM 留 64，51.1→46.4；先由 VisionZip 留 128 再压到 64，升至 52.5（Table 5）。

### 边界

方法不减少视觉塔成本；dominant token 是视觉塔的信息 proxy，不必位于语义对象原位置。文本无关有利于多轮复用，却可能错过当前安全政策所需的稀有细节；softmax 导致 proxy 集中的解释仍是有干预支持但未被因果证明的假说。

## 6. DivPrune：极端压缩下优先覆盖不同语义簇

### 问题场景

DivPrune 针对 importance ranking 在高压缩时反复保留相似 token 的失败。用户输入是图像或 8 帧视频加问题，模型做 caption、QA 与推理；重点是 80% 以上剪枝、低时延或资源受限部署（§1）。

### 方法

将保留集选择写成 max-min diversity：最大化任意两保留 token 间的最小 cosine distance。算法先选最近邻距离最大的 token，再不断加入离已选集合最远的候选；默认在 LLM layer 0 前一次执行，未选 token 直接丢弃（Equation 3–4、Algorithm 1）。

### 实验效果

- 11 个图像数据集、5 个视频数据集；LLaVA-1.5-7B/13B、LLaVA-1.6-7B、LLaVA-NeXT-Video-7B。
- LLaVA-1.5-7B 约 15.6% TFLOPs：DivPrune 的 COCO/GQA/MMBench/POPE 为 0.96/56.85/59.19/86.02，FastV 为 0.06/38.73/20.62/32.84（Table 1）。
- LLaVA-NeXT-Video 为原 14.1% TFLOPs：ActivityNet 2.56/45.90、SeedBench 37.00、EgoSchema 39.76；原模型为 2.67/48.10、38.7、41.8（Table 2）。
- 同一视频实验中，显存 14.06→13.51GB，prefill 0.330→0.161s，E2E 4.37→3.39s；selector 使 prefill 比 FastV/VTW 略慢，但只算一次，E2E 反而略快。
- Random 四项平均 56.66、Min-Max 46.53、DivPrune 62.34；layer 0 剪为 62.34，延迟到 layer 3 只剩 38.60（Tables 3–4）。

### 边界

embedding 多样性不等于空间、时间或风险语义覆盖，且纯删除不保留摘要。安全 Guard 更适合把 diversity 作为政策相关 Top-k 的覆盖约束或回收聚类依据，而非唯一选择器。

## 7. SafeWatch：政策条件化长视频安全剪枝

### 问题场景

SafeWatch 的输入是视频、多条以自然语言写成的政策定义/允许项/禁止项/示例，以及审核 query；输出是安全相关视频描述、每政策二值 flag 与逐政策解释。任务存在四个特有难点：危险可能短暂出现；同一视频可触发多标签；平台政策会改变且顺序不应造成偏置；hard-benign 会造成高误报（§1、§3.1）。

SafeWatch-Bench 有 2M 视频，覆盖 Sexual、Abuse、Violence、Misinformation、Illegal、Extremism 六类和 30 余细分任务，分 Real 与 GenAI 两部分，并提供多标签与解释（§4）。

### 方法

1. Safety-aware event sampler 先分割潜在危险事件，每事件采一帧；
2. PEPE 把长政策拆成独立 chunk，跨政策 mask，并用等价 RoPE 位置并行编码，缓解位置偏置；
3. PAP 计算每政策 query 与视频 key 的 cross-attention，为每政策保留 Top-k 视觉 token，更新 KV cache；
4. 三阶段训练依次做多任务 guard、pruning-aware guard 与偏好后训练（§3.1–§3.4，pp. 4–7）。

### 实验效果

- SafeWatch-Bench-Real：ACC/F1/AUPRC 72.6/86.7/98.8，GPT-4o/人评解释 7.17/8.21，3.9s；同底座 InternVL2-8B 为 29.1/41.1/80.1、5.07/4.41、4.3s（Table 1）。
- GenAI 平均 ACC 72.0，GPT-4o 44.8；外部 LSPD/XD-V/UCF/FakeSV/FVC 为 93.8/93.8/96.4/71.9/79.8（Tables 2–3）。
- 未见政策 children/firearms/accidents 为 81.8/87.8/78.5；随机政策顺序、定制白名单、仅标签、QA 为 64.7/64.5/91.4/80.8（Tables 4–5）。
- Figure 5 报告剪到 90% 时平均性能下降小于 1%；但 PR-95/99 的 accuracy 已降到 65.3/55.9，说明安全预算存在陡峭失效区（Table 6）。
- 完整模型 accuracy/explanation/adaptability 为 72.6/7.17/82.7，去 PAP 为 69.9/6.83/79.1；三训练阶段则为 63.9→67.3→72.6 accuracy，说明质量来自模块与训练共同作用（Tables 6、8）。

### 边界

论文没有报告逐风险 fixed-FPR recall、worst-group、P95 time-to-verdict、帧/框级证据忠实度。平均 accuracy 保持不能证明极端危害漏报不变；事件分割若先漏掉短危险，PAP 无法恢复。自然语言 explanation 质量高也不等于对保留 token 的因果归因忠实。

## 跨论文比较：真正的分歧在哪里

### 文本相关性不是总是越多越好

TRIPS、PuMer、SparseVLM、SafeWatch 都说明 query/policy 会改变相关视觉证据；但 VisionZip 指出视觉塔已把信息汇聚到位置不直观的 proxy token，LLM attention 可能选错承载信息的位置。DivPrune 又说明 Top-k relevance 会在高压缩时重复。合理结论是：**相关性负责“当前要什么”，视觉聚合/多样性负责“证据在哪里、覆盖是否完整”**，两者应联合而非互相替代。

### 剪枝位置决定可节省什么

| 位置 | 方法 | 可节省 | 已经付出的成本 | 主要风险 |
|---|---|---|---|---|
| 视觉主干内部 | TRIPS | 后续视觉层+融合层 | 早期视觉层、文本编码 | 架构耦合；需文本提前可用 |
| 跨模态 encoder 内 | PuMer | 后续融合层 | 视觉塔/文本塔 | 融合层不是瓶颈时收益小 |
| LLM 内部 | FastV、SparseVLM | 后续 LLM/部分 KV | 视觉塔+浅层 prefill | 当前 prompt 过拟合、跨轮不可恢复 |
| LLM 前 | VisionZip、DivPrune | 全部 LLM prefill/KV/decode | 完整视觉塔+selector | task-agnostic 漏稀有证据 |
| 事件采样+LLM 内 | SafeWatch | 帧数、政策编码、视频 token | 分割器与安全专门训练 | 上游漏事件会不可恢复 |

### FLOPs、prefill 与端到端不是同一个指标

VisionZip 的 prefill 7.8× 对应总时间约 3×；DivPrune 的 prefill 约快 55% 对应 E2E 约快 22%；SafeWatch 的 prefill GFLOPs 变化不到 1%，平均单视频时间仍从同底座 4.3s 到 3.9s。输出长度、selector、视觉塔、kernel 与 batch 都会改变净收益，跨论文不能只按 token ratio 排名。

## 对多模态安全判别研究的建议

### 推荐方法组合

1. **场景入口：** 先做 SafeWatch 式安全事件采样；原始均匀帧采样作为必需对照，专门构造只在 1–2 帧出现的危险事件。
2. **重要性：** 用政策/任务条件相关性作为主信号，优先考虑 policy-query × visual-key，而不是通用 PPL。
3. **覆盖约束：** 在相关性 Top-k 中加入 DivPrune 式语义多样性、空间网格覆盖与跨帧覆盖，防止所有预算集中到同一对象或同一帧。
4. **信息回收：** 对被删集合保留 PuMer/VisionZip/SparseVLM 式聚合摘要；高风险类别或低置信样本允许恢复原 token 或升级预算。
5. **多轮与政策变化：** 若视频 embedding 会被多轮复用，保留一个 task-agnostic base cache，再为每轮政策附加少量 policy-conditioned tokens；不要只缓存上一轮 Top-k。
6. **训练策略：** 把 training-free selector 作为诊断基线，但安全主模型应加入 pruning-aware training；SafeWatch 的 Stage-2 结果说明分布适应不可省略。

### 必需基线

- 无剪枝、Random、uniform spatial/temporal pooling；
- FastV 或 SparseVLM：prompt-conditioned decoder 内路线；
- VisionZip：视觉 proxy + merging；
- DivPrune：coverage/diversity；
- SafeWatch PAP：政策条件化直接基线；
- 相关性-only、diversity-only、hybrid、hybrid+recycling、risk fallback 的逐项消融。

### 必需评价

- **安全质量：** 每类 recall/precision/F1、fixed-FPR recall、AUPRC、worst-group、hard-benign FPR、校准误差、漏报成本加权风险；
- **证据能力：** OCR、小目标、组合图文危害、图文冲突、短暂视频事件、跨帧因果、多轮政策切换；
- **解释：** 文本质量之外，报告删除/恢复 token 对输出的因果敏感性、帧/区域 provenance；
- **系统：** vision encode、selector、prefill/TTFT、time-to-verdict、decode、E2E P50/P95、KV/peak memory、batch throughput；
- **预算曲线：** 不只报一个平均点，画每类风险随 token budget 的曲线并找安全失效拐点。

## 证据状态

七篇均按正式论文原文 deep-read，关键数字已回查正文、表格与附录，verification 为 `source-checked`；本轮没有本地复现实验。不同论文硬件、主干、batch、任务和综合指标均不一致，数字仅用于理解各论文内部的质量—效率关系，不能直接形成统一排行榜。

## 逐篇笔记

- [[LLM-Wiki/research/visual-token-pruning/papers/2022-jiang-trips.md|TRIPS]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2023-cao-pumer.md|PuMer]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2024-chen-fastv.md|FastV]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-zhang-sparsevlm.md|SparseVLM]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2025-yang-visionzip.md|VisionZip]]
- [[LLM-Wiki/research/visual-token-pruning/papers/2025-alvar-divprune.md|DivPrune]]
- [[LLM-Wiki/research/safety-classifier-compression/papers/2025-chen-safewatch.md|SafeWatch]]
