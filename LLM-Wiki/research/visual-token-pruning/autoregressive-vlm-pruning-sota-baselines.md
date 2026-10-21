---
id: autoregressive-vlm-pruning-sota-baselines
type: synthesis
title: "多模态自回归模型视觉 Token 剪枝：时延与性能 SOTA 基线"
tags: [research, visual-token-pruning, efficient-inference, multimodal-models]
project_id: visual-token-pruning
sources: [paper-peng-2025-uniprunebench, paper-chen-2024-fastv, paper-zhang-2025-sparsevlm, paper-alvar-2025-divprune, paper-yang-2025-visionzip, paper-khaki-2025-sparsevila, paper-he-2025-zipvl, paper-yang-2025-vflowopt, paper-zhang-2026-vscan, paper-gao-2026-quietprune, paper-zhu-2026-hawk, paper-sun-2026-if-prune, paper-li-2026-occamtoken, paper-chen-2026-v2drop, paper-chen-2026-evoprune, paper-wang-2026-stc, paper-ou-2026-sieve, paper-liu-2026-pace, paper-tong-2025-flowcut, paper-liu-2025-meteor, paper-hu-2026-illava, paper-yang-2025-visionthink, paper-lin-2026-adaptvision, paper-kim-2026-zoo-prune, paper-endo-2025-feather]
status: active
created: 2026-09-16
updated: 2026-10-16
---

# 多模态自回归模型视觉 Token 剪枝：时延与性能 SOTA 基线

## 范围与口径

主检索截止 2026-09-16，2026-09-17 定向复核以下基线的任务、batch 和计时边界。纳入图像/视频经视觉编码器产生连续视觉 token、再由自回归 LLM 解码的 VLM；排除纯 ViT 分类、扩散模型 token 剪枝、纯权重量化与仅报告 FLOPs 而无实测时延的工作。`SOTA` 只表示本轮从可访问原文核到的最好公开点，不表示在异构硬件、输入长度和任务之间存在单一全局冠军。

时延必须区分：视觉编码器、LLM prefill、TTFT、decode throughput/generation latency 与 end-to-end/total runtime。性能保持率是论文定义的多任务归一化平均，不能与某个单独 VQA/OCR 分数直接横比。论文自报值与 UniPruneBench 统一复现值分开解释。

## 2026-10-16：用户选定的四项待补比较

用户明确选定 **VisionThink、AdaptVision、ZOO-Prune、FEATHER**，计划后续补充实验。本节只登记候选、正式来源、代码入口和比较边界；四项本地比较均待执行，不将论文自报结果写成当前 Guard 的实测结果。下方历史数值表仍保持原检索与计时审计范围。

| 待补方法 | 原文与实现入口 | 对当前研究的比较作用（项目判断） | 证据与待办 |
|---|---|---|---|
| VisionThink，NeurIPS 2025 | [正式论文](https://proceedings.neurips.cc/paper_files/paper/2025/hash/88be023075a5a3ff3dc3b5d26623fa22-Abstract-Conference.html)；[作者代码](https://github.com/dvlab-research/VisionThink)；[[LLM-Wiki/research/visual-token-pruning/papers/2025-yang-visionthink.md]] | 低分辨率起步、按样本请求原高清图；用于比较全局分辨率升级与自适应预算 | 复用既有来源及 v1 skimmed / source-checked 笔记，补正正式 venue/作者；RL、二次推理及升级成本不能省略；Qwen3-VL-2B Guard 适配与实测待做 |
| AdaptVision，CVPR 2026 | [论文](https://arxiv.org/abs/2512.03794)；[作者代码与模型](https://github.com/AdaptVision/AdaptVision) | 低清全局后按需裁剪局部；直接检验全局/局部获取路线的增量 | 新登记 discovered；仅核题录、摘要及代码入口，未精读。完整系统经过 RL 并含工具调用，不能把不同权重的效果算成同 Guard 选区收益；本地适配、质量与全流程成本待做 |
| ZOO-Prune，CVPR 2026 | [作者项目与论文入口](https://aim-skku.github.io/ZOO-Prune/)；[作者代码](https://github.com/AIM-SKKU/ZOO-Prune) | 投影层零阶敏感度结合多样性，补充输出相关重要性选择 | 新登记 discovered；CVF 原文请求失败，未核全文。需核对敏感度代理、选择开销和 Qwen3-VL 适配；不能直接称为安全因果贡献；本地实验待做 |
| FEATHER，ICCV 2025 | [论文](https://arxiv.org/abs/2412.13180)；[作者项目](https://web.stanford.edu/~markendo/projects/feather)；[作者代码](https://github.com/markendo/FEATHER) | 针对早层剪枝的空间偏差，用均匀覆盖及多阶段选择补充 FastV | 新登记 discovered；仅核作者项目、题录和 README，未精读。原实现基于 Prismatic/Llama2，需核对 Qwen3-VL 位置机制与剪枝规则；局部证据和安全召回待评测 |

共同待办：在明确的权重/训练条件、同一测试划分及可比执行后端下评测，分报选择/裁图/视觉编码/prefill/最终输出的实际成本，并报告政策 Guard 的危险漏检、误报及压缩诱发翻转。相同保留 token 数不能替代端到端成本匹配；原方法与适配版本分别标识。本轮不运行模型、不修改 Cx 方法或正式 motivation，也不自动改变 watch 候选决定。

## 结果表

| 方法 | 位置与简介 | 模型 / Token 预算 | 时延数据 | 性能数据 | 证据状态与来源 |
|---|---|---|---|---|---|
| UniPruneBench：GPrune / DivPrune | 统一复现；ViT 输出侧代表性传播 / 多样性子集选择 | InternVL3-8B；保留 11.1% | A100-40GB、batch 1、MME：GPrune total 761→454 s（1.68×），prefill 320→167 s（1.92×）；DivPrune 469 s（1.62×）/185 s（1.73×） | 九任务均值：Vanilla 70.02；GPrune 63.31；DivPrune 64.04（同预算最高） | 统一复现，arXiv v2；[UniPruneBench](https://arxiv.org/abs/2511.02650) |
| FastV / SparseVLM | FastV 在 LLM 第 2 层后按 attention 剪；SparseVLM 用文本相关性渐进剪枝并回收 token | 统一基准：LLaVA-v1.5-7B，保留 22.2%；另有 InternVL3-8B 11.1% FastV | InternVL3-8B 11.1%：FastV total 1.53×、prefill 1.51× | LLaVA-v1.5-7B 22.2%：SparseVLM 53.5，Vanilla 53.2；FastV 45.5。说明旧强基线仍需保留，但不跨模型外推 | 统一复现 + 原论文；[UniPruneBench](https://arxiv.org/abs/2511.02650)、[SparseVLM](https://proceedings.mlr.press/v267/zhang25s.html) |
| VisionZip | 视觉塔后保留 dominant tokens，并把上下文 token 聚合到代表 token；兼顾多轮复用 | LLaVA-NeXT；约 5% token 的极限配置 | 最高 8× prefill 加速；不是端到端 8× | 约 5% token、无适配保持 92.0%；少量 projector 调优配置可达 Vanilla 的 98.9%（非同一配置） | CVPR 2025；[VisionZip](https://openaccess.thecvf.com/content/CVPR2025/html/Yang_VisionZip_Longer_is_Better_but_Not_Necessary_in_Vision_Language_CVPR_2025_paper.html) |
| SparseVILA | prefill 做 query-aware retrieval，decode 对视觉 token 使用稀疏 attention；上下文与生成阶段解耦 | LLaVA-NeXT/LongVILA；长上下文与多轮 | 图像基准 1.4×；长任务 prefill 3.6×、decode 1.7×；A6000、batch 1 | 图像任务平均比先前方法高 5.9 个点；长上下文检索接近 Vanilla | ICCV 2025；[SparseVILA](https://openaccess.thecvf.com/content/ICCV2025/html/Khaki_SparseVILA_Decoupling_Visual_Sparsity_for_Efficient_VLM_Inference_ICCV_2025_paper.html) |
| ZipVL | 层级动态稀疏比例、归一化 attention 选择与稀疏 attention；被删 token 不进入 KV cache | LLaVA-NeXT-13B；自适应 token 比例 | A100：128K 输入、batch 1 的 TTFT 48.01→20.57 s（2.33×）；16K decode throughput 约 2.8×，但使用各方法能容纳的最大 batch，非同 batch / batch 1 的 decode 加速 | VQAv2 仅下降 0.5%，不绑定到 128K 时延工作点 | ICCV 2025 Table 5；[ZipVL](https://openaccess.thecvf.com/content/ICCV2025/html/He_ZipVL_Accelerating_Vision-Language_Models_through_Dynamic_Token_Sparsity_ICCV_2025_paper.html) |
| VFlowOpt | 依据信息流渐进剪枝、回收被删 token，并离线搜索剪枝策略 | LLaVA-OneVision-7B；剪 90% | A100-SXM4-80GB、MME：平均 inference latency 1040.1→272.1 ms（3.82×）；KV cache 减少 89%；batch 和视觉/完整 decode 的计时边界未明确 | 同一 Table 5 的 MME 1581→1464（-7.4%），不是无损工作点 | ICCV 2025；[VFlowOpt](https://arxiv.org/html/2508.05211v2) §4.4/Table 5 |
| VScan | 视觉塔输出端按全局/局部扫描选择并合并，LLM 中层再按文本相关性剪枝；不是 ViT 内早剪 | LLaVA-NeXT-7B；平均保留 11.1% | total 2294→1120 s（2.05×）；prefill 1420→488 s（2.91×） | 16 项平均保持 95.4%；POPE 85.1 vs 86.5 | TMLR 2026；[VScan](https://arxiv.org/abs/2505.22654) |
| QuietPrune | 轻量 adapter 把 query 映入视觉空间，以 `[Q-CLS]` 在 ViT 内做 2×2 半结构化早剪并聚合被删 token | Qwen3-VL-4B / InternVL3-1B/8B；平均剪 50% | prefill latency 分别降低 33.1% / 42.1% / 49.3%；相对最佳 late-pruning 最多再多降 19.0 个百分点 | 相对准确率 95.7% / 98.5% / 97.4%；相对 late-pruning 最多高 4.2 个点 | CVPR 2026；[QuietPrune](https://openaccess.thecvf.com/content/CVPR2026/html/Gao_QuietPrune_Query-Guided_Early_Token_Pruning_for_Vision-Language_Models_CVPR_2026_paper.html) |
| HAWK | 对 attention head 先估重要性，再用加权文本引导 attention 选择视觉 token；免训练 | Qwen2.5-VL-7B；时延表剪 80% | MME 整套作者称 E2E latency：20:15→15:04（1.34×）；不是单请求 15 分钟；效率单卡，batch 和具体 GPU 型号未明确 | 时延表同点 MME 2315→2311；摘要 96.0% 是多任务配置，非该 MME 分数 | CVPR 2026；[HAWK](https://arxiv.org/html/2604.07812v1) §4.1/4.5/Table 5 |
| IF-Prune | 用带变分信息瓶颈的小 VLM 估计 query 条件下的非信息 token，再指导大 VLM 剪枝 | 大 VLM；保留 5% | 官方摘要未给可比实测时延 | 保持 95% 原性能，比其对照 SOTA 高 8 个点 | CVPR 2026；[IF-Prune](https://openaccess.thecvf.com/content/CVPR2026/html/Sun_IF-Prune_Information-Flow_Guided_Token_Pruning_for_Efficient_Vision-Language_Models_CVPR_2026_paper.html) |
| OccamToken | 以 register token 为相对证据锚点，自适应做图像冗余和 query relevance 双重剪枝 | LLaVA-NeXT；约 2880→40 token（1.4%） | 摘要未给 wall-clock 时延 | 极限 1.4% 保留率仍保持超过 93% 原准确率 | arXiv 2026；[OccamToken](https://arxiv.org/abs/2605.29657) |
| V2Drop | 在 LLM 内按跨层 token variation 渐进删除，针对可部署高效算子设计 | LLaVA-1.5-7B / LLaVA-OV-7B | 图像 LLM-only -31.5%，full-model response -23.1%，整套 MMBench -20.8%；视频分别 -74.2% / -46.5% / 整套 MVBench -27.5%。不能把 3.88× 写成视频端到端加速 | Table 5 对应性能保持 95.7% / 99.1%；摘要汇总的 94.0% / 98.6% 属于其他预算，不绑定同工作点 | CVPR 2026；[V2Drop](https://arxiv.org/html/2509.01552v2) Table 5 |
| EvoPrune | 在视觉编码器 Attention 与 MLP 之间按相似性、多样性和 attention 做隔层评分引导合并；不是纯 drop | LLaVA-Video-7B，H20 | 作者摘要称 VideoMME 推理 2×；Table 2 的 overall 包含 pre-LLM 与 LLM，64 帧×64 token 为 0.55× 时延（1.82×）；Figure 3 明确为 TTFT，尚未核清 overall 是否包含完整解码 | Table 2 同点多视频基准平均相对性能 99.7%；不把摘要速度与任意预算准确率拼接 | arXiv v1；[EvoPrune](https://arxiv.org/html/2603.03681v1) §4.2–4.3 |
| STC | 流式 VideoLLM：相似帧特征缓存 + 时空相关 token 剪枝，分别省 ViT 与 LLM | ReKV 等流式视频模型 | ViT 编码时延 -24.5%；LLM prefill -45.3% | 最多保持 99% 准确率 | CVPR 2026；[STC](https://openaccess.thecvf.com/content/CVPR2026/html/Wang_Accelerating_Streaming_Video_Large_Language_Models_via_Hierarchical_Token_Compression_CVPR_2026_paper.html) |
| SIEVE | 在 LLM 中结合文本子空间不可解释残差、文本相关性与 residual-space diversity；免训练 | LLaVA-NeXT-7B；保留 11.1% | POPE total 46:11→18:32（2.49×）；prefill 37:21→10:20（3.62×）；KV cache 1156→192 MB | 八任务平均保持 97.5%；POPE F1 85.7 vs 86.5 | arXiv 2026 v1；[SIEVE](https://arxiv.org/abs/2608.10489) |
| PACE | pre-encoder 自适应像素压缩 + LLM 浅层双 attention 提取；同时动视觉编码和 prefill | Qwen2.5-VL-7B；保留 10%；RTX 4090 | encoder 148.84→49.47 ms（3.01×）；prefill 217.05→32.69 ms（6.64×）；含预览开销 TTFT 365.89→116.79 ms（3.13×） | 九任务归一平均保持 93.8%；OCRBench 70.9 | Findings of EMNLP 2026 / arXiv v1；[PACE](https://arxiv.org/abs/2608.27206) |

## 2026-09-17：推理任务、环境与计时口径审计

本节只审计已列方法，不构成新增实验或全领域重新排名。`未明确` 表示所核正文/效率段落未足以确认，不能据单卡、item/s、算法伪代码中的 batch 维或数据集逐样本描述认定请求 batch。视频帧数与 AnyRes tiles 数也不是请求 batch。

### 口径定义（综合整理）

- 模型级完整响应：视觉编码、selector/merge/compact、LLM prefill 和完整自回归 decode；是否包括 CPU 图像预处理、数据传输和文件读取须另外确认。
- TTFT/prefill：到首 token 为止；有的论文含视觉编码，有的仅计 LLM，因此不能只看名称。
- 数据集 total runtime：完成整套离线 benchmark 的累计时间，不是单请求 P50/P95；计时是否还包含加载、打分等框架步骤因论文而异。
- 服务级端到端：请求到达至最后 token 返回，还含队列、调度、网络及预处理；本次没有核到这组基线的统一并发服务级结果。

### 逐方法证据

| 方法 / 来源位置 | 时延测量任务与推理环境 | 请求 batch 与 batch 加速证据 | 计时边界与可用结论 |
|---|---|---|---|
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-peng-uniprunebench.md]] §4.1/4.3/Table 4 | InternVL3-8B；MME yes/no 答案生成；PyTorch/VLMEvalKit、A100-40GB、3 次运行 | 明确 batch=1；无本表固定大 batch 扫描 | total 为整套 MME，含完整评测流水线；prefill 为 decode 前混合视觉/文本前向、构建 KV，不是单独 ViT。GPrune 1.68× total / 1.92× prefill 是 batch 1 的离线工作负载证据 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-yang-visionzip.md]] CVPR Table 4/§3.3 | LLaVA-NeXT-7B；POPE yes/no 生成；单 A800-80GB；2880→160 token | 推理 batch 未明确；训练 8 卡或伪代码 B 不作证据 | total 整套 POPE 2293→756 s（3.03×）；作者把 218→27.8 ms 称首 token/prefill（7.84×），但未清晰定义是否含 ViT；不是完整答案 8× |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-khaki-sparsevila.md]] ICCV §4.4；arXiv v1 Inference Setting/Latency Evaluation | 旧表：图像 VQA 与长上下文/长生成、多轮；A6000、AWQ/TinyChat 优化。后续 arXiv v1：W8A8 视觉、W4A16 LLM、greedy | 明确 batch=1；没有据此证明请求大 batch 加速 | ICCV 自报 1.4× 图像、3.6× prefill、1.7× decode。后续 v1 明确定义 E+P+D：图像每轮固定 50 tokens、视频 250、reasoning 单轮 1500；其 2.6× E2E 不是旧版同表，且相对量化基线，不能叠乘为剪枝收益 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-he-zipvl.md]] ICCV Table 5 / arXiv v2 §5.4 | LLaVA-NeXT-13B；A100；8K–128K 输入长度的 prefill/decode 性能测量，质量另测 VQA | TTFT 明确 batch=1；decode throughput 用各方法单卡最大可容纳 batch，实际数值未列 | 128K TTFT 2.33×；16K TTFT 2.64→2.61 s，仅约 1.01×。16K decode 14.10→40.87 tokens/s（约 2.9×，作者概括 2.8×）含大 batch 容量收益；未核清视觉编码是否进入计时，不是完整生成 E2E |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-yang-vflowopt.md]] §4.4/Table 5 | LLaVA-OneVision-7B；MME 短答案生成；单 A100-SXM4-80GB；所有样本平均 | batch 未明确；正文只论述大 batch 潜力，非实测曲线 | 作者 inference latency 1040.1→272.1 ms（3.82×）；视觉、prefill、完整 decode 起止未逐项说明，不当作已确认完整 E2E 或 batch 1 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhang-vscan.md]] §5.4/Table 5 | LLaVA-NeXT-7B；POPE yes/no 生成；所核正文未明确该表 GPU；另有 FlashAttention 实验 | batch 未明确 | total 为所有 POPE 样本 2294→1120 s（2.05×）；prefill 累计 1420→488 s（2.91×）。属于离线生成评测，不是单请求 1120 s，也不是长答案吞吐结论 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-gao-quietprune.md]] §5.1/Figure 2/Table 1 | Qwen3-VL-4B / InternVL3-1B/8B；六项 VQA/OCR/推理生成基准；VLMEvalKit、单 A100、eager attention，按 benchmark 样本平均 | 主文 batch 未明确 | 重点是含视觉编码与 LLM prefill 的阶段成本；prefill -33.1%/-42.1%/-49.3%，没有报告同点完整答案 decode/E2E 加速 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-zhu-hawk.md]] §4.1/4.5/Table 5 | Qwen2.5-VL-7B；MME；VLMEvalKit；效率单卡，具体 GPU 型号未明确。8×96GB 描述的是质量评测环境 | batch 未明确；8 卡不等于请求 batch=8 | 作者称 E2E，但数字是整套 MME 20:15→15:04（1.34×），未细拆预处理/生成起止；不是线上服务 E2E |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-v2drop.md]] Table 5/Appendix A | 图像 MMBench / 视频 MVBench 选择题答案生成；LLaVA-1.5/OV-7B；A100-PCIe-80GB，Python 3.10、PyTorch 2.1.2、CUDA 12.1 | batch 未明确；item/s 不足以证明多请求 batch | 明确区分 LLM-only、full-model response 与整套 total；视频 752.2→193.8 s 是 LLM-only，1201.6→642.4 s 才是 full model；整套 32:02→23:13。图像整套 10:14→8:06 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-chen-evoprune.md]] §4.2–4.3/Table 2/Figure 3 | LLaVA-Video-7B；VideoMME/MVBench/LongVideoBench 选项生成；单 H20；64 帧输入 | batch 未明确；64 帧不是 64 请求 | 作者 overall 包含视觉/剪枝与 LLM，64×64 token 时延 0.55×；另给 TTFT 分解。完整 decode 是否计入 overall 未清，不提升为严格全输出 E2E |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-wang-stc.md]] §4.1/Tables 1–2 | ReKV/LLaVA-OV-7B；OVO-Bench/StreamingBench 的流式视频问答；0.5 fps 协议；所核正文 GPU 未明确 | 请求 batch 未明确；16 帧编码不是请求 batch=16 | 只明确 ViT 编码 16 帧与 LLM prefill 两阶段：-24.5%/-45.3%，没有全答案生成 E2E 时延；online 模型不自动等于报告 online 服务响应时间 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-ou-sieve.md]] §Efficiency Analysis/Table 6 | LLaVA-NeXT-7B；POPE yes/no 生成；11.1% 保留；所核正文硬件未明确；给出 FlashAttention-compatible 评分 | batch 未明确 | 作者称 2.49× E2E，但表为整套 total 46:11→18:32；prefill 37:21→10:20（3.62×）；无服务级并发或固定长输出证明 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-liu-pace.md]] §4.3/Table 2/Appendix A.3 | Qwen2.5-VL-7B；DocVQA/TextVQA profiling；固定分辨率、10% 预算；单 RTX 4090、greedy | batch 未明确 | 明确仅 TTFT，不加速自回归 decode：视觉+prefill+preview/resize 共 365.89→116.79 ms（3.13×）；不称完整答案 E2E。stage 列不含 34.62 ms 预览/resize，但 TTFT 含 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-tong-flowcut.md]] Table 5 | LLaVA-1.5/NeXT-7B；POPE yes/no 生成；单 A800 | batch 未明确 | total 是整套 POPE：1.5 模型 17:05→11:17（1.51×），NeXT 35:16→11:40（3.02×）；prefill 分别 102→62.6 / 206→63.8 ms；不是仅 ViT latency |
| [[LLM-Wiki/research/visual-token-pruning/papers/2026-hu-illava.md]] §4.6/Figure 4/Table 4 | MMMU 生成式选择题效率分析；所核主文未明确具体 profiling GPU | batch 未明确；throughput 字段不足以认定大 batch | 作者最高 2.12× model throughput、4.46× prefill（定义首输出 token）；吞吐起止/输出长度未充分明确，不当作完整生成 E2E 或单请求证据 |
| [[LLM-Wiki/research/visual-token-pruning/papers/2025-liu-meteor.md]] §4.2/主表 | EAGLE 多视觉塔；11 项 VQA/OCR/chart 生成式任务；Ascend 910B | batch 未明确；离线 rank 估计的小批量不是推理 batch 证据 | throughput 0.81→1.18（1.46×），但该列单位、完整 decode/预处理起止未足以确认；不当作严格 E2E 或 batch 1 |

### 批处理与任务类型结论（综合判断）

有明确 batch 1 实测证据：UniPruneBench 的完整离线 benchmark，ZipVL 的 TTFT，SparseVILA 的优化生成流水线；三者优化目标并不相同。ZipVL 还提供可变最大 batch 的 decode throughput 证据，但不是固定 batch 的每请求时延比较。其余设置不全的论文不因未报告而判定不支持 batch，只是不将其数字用于已证明 batch 1 / 固定大 batch / 服务级 E2E 的排名。

MME/POPE 的 yes/no、MMBench/MMMU/VideoMME 的选项均通过自回归 VLM 产生；准确率/F1 是答案评分，不等于分类头计算。长生成的对照可参考 SparseVILA 后续 v1 的固定输出协议，但它是设定生成长度的模型级 profiling，不是线上并发负载。

更早 [[LLM-Wiki/research/visual-token-pruning/token-merging-landscape.md|合并方法表]] 的 DTEM（3090、batch 128、fp32、im/s）和 STViT（V100、batch 128、im/s）是 ImageNet 分类吞吐；不能转用为自回归 MLLM 端到端或者 batch 1 时延证据。FiCoCo-V/AdaptMerge 的 FLOPs 数据也不作为实测加速。

复现建议（未执行）：在同模型/硬件/量化/attention 后端下固定请求 batch=1/2/4/8/16、输入像素/视觉 token 和文本长度，并设输出 1/32/128/512 tokens；分报预处理、视觉、selector/compact、LLM prefill、decode、完整模型响应，以及真实长度输出的任务质量。服务层另报吞吐、P50/P95 TTFT/E2E、并发与动态 shape/padding 策略，不用最大 batch 吞吐替代固定 batch 时延。

## 判断

- **同硬件统一基线：** 当前最可信的直接比较是 UniPruneBench。InternVL3-8B、A100-40GB、11.1% token 下，GPrune 的总时延最快（1.68×），DivPrune 的九任务均值更高（64.04 vs 63.31）；两者都远低于 Vanilla 70.02，说明极限剪枝仍有明显精度代价。
- **论文自报端到端/TTFT 前沿：** 图像 VLM 中，SIEVE 给出 2.49× total runtime 且保持 97.5% 平均性能；PACE 给出 3.13× TTFT 且保持 93.8%，但它通过输入像素压缩同时改动视觉编码成本，口径不同。VFlowOpt 的 3.8× “inference”数值更高，但 batch/计时边界未明确，且同点 MME 下降 7.4%，不宣布完整端到端总冠军。
- **极限性能保持：** IF-Prune 在 5% token 保持 95%，OccamToken 在约 1.4% token 仍保持超过 93%；二者摘要未给同口径 wall-clock，属于性能—预算 SOTA 候选，而非已证实时延 SOTA。
- **视频场景：** V2Drop 的 74.2% 是 LLM-only；完整模型响应降低 46.5%，整套 MVBench 降低 27.5%。EvoPrune 的 overall/TTFT 与完整 decode 边界尚待核；STC 报双阶段而非全答案时延。这些不同工作负载不能与单图 TTFT 横排。
- **风险边界：** UniPruneBench 发现随机剪枝仍是强基线、OCR 对剪枝最敏感、没有方法跨模型/预算普遍最优。部署评测至少应同时报告 Random、固定网格/池化、输入降采样、FastV、DivPrune/SparseVLM，以及目标方法的 selector/compact 开销。

## 证据边界

本页未运行论文代码，所有数值都是来源自报或 UniPruneBench 的统一复现。2026 年 8 月的 SIEVE 与 PACE 仍是新论文；需要把它们放进相同模型、分辨率、输出长度、FlashAttention 配置和硬件后，才能给出严格 Pareto 排名。分类/安全 Guard 的短输出场景通常比开放式长生成更难获得 decode 侧收益，宜优先看 TTFT 与总请求时延而非 token/s。
