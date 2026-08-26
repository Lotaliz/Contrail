---
id: safety-classifier-compression-gaps
type: synthesis
title: 安全判别剪枝与蒸馏研究缺口
tags: [research, method]
project_id: safety-classifier-compression
sources: [paper-fedorov-2024-llama-guard-int4, paper-lee-2025-harmaug, paper-lee-2025-saferoute, paper-verma-2025-multiguard, paper-chi-2024-llama-guard-vision, paper-palo-2024-pgkd, paper-wang-2024-p-pruning, paper-wang-2024-smarttrim, paper-lin-2024-mope-clip, paper-yang-2025-visionzip, paper-chen-2025-safewatch, paper-lin-2020-autoregressive-kd, paper-agarwal-2024-gkd, paper-gu-2024-minillm, paper-ko-2024-distillm, paper-ko-2025-distillm2, paper-zhang-2026-prefix-opd, paper-jang-2026-veto-opd, paper-fu-2026-opsa-safety, paper-fairoze-2026-controlled-release, paper-nasr-2026-attacker-moves-second, paper-zhang-2026-mtk, paper-zhang-2026-vsg-safe]
status: active
created: 2026-08-24
updated: 2026-08-25
---

# 研究缺口

## G1：压缩后困难样本与新型攻击的安全保持缺少统一协议（满足 Motivation 门槛）

- 支持：HarmAug 需要主动生成多样有害指令才能弥补朴素蒸馏的性能缺口；SafeRoute 的 oracle 显示小 Guard 的错误集中在少量可由大 Guard 纠正的样本；Llama Guard 3-1B-INT4 也明确承认类别、语言和对抗攻击上的能力差异。
- 反证：HarmAug 已覆盖 OAI、ToxicChat、HarmBench、WildGuardMix，并验证新 jailbreak 微调；并非完全没有鲁棒性评测。
- 边界：不能由此断言压缩必然降低安全性；HarmAug 的小模型在部分指标上超过教师。
- 待验证：在固定 FPR、跨 taxonomy、策略更新、混淆改写和 jailbreak 变体下，剪枝率、学生规模、校准误差与 per-category recall 如何共同变化？

## G2：端到端成本核算忽略教师调用和数据生成的摊销边界（满足 Motivation 门槛）

- 支持：PGKD 的教师循环会持续生成新样本且论文明确把该成本列为限制；HarmAug 生成 100k 有害指令、响应并由 8B Guard 标注；MobileCLIP 则通过一次离线强化数据供多个架构复用来摊销教师成本。
- 反证：当模型长期高流量服务时，离线成本可被大量请求摊薄，在线节省仍可能占主导。
- 边界：该缺口针对频繁变化的政策、小流量模型和多模型家族；不否定静态大规模部署的收益。
- 待验证：以策略更新周期、流量和学生数量为变量，何时在线蒸馏、离线缓存教师信号或直接微调最省总成本？

## G3：结构稀疏的真实设备收益与算法指标脱节（满足 Motivation 门槛）

- 支持：P-pruning 报告真实 fine-tuning speedup；Llama Guard 3-1B-INT4 在手机 CPU 上测量；Wanda 主要证明精度保持和剪枝速度，非结构化稀疏的端到端收益依赖 kernel。
- 反证：半结构化 N:M 在支持硬件上可以稳定加速；不能把所有稀疏方法视为不可部署。
- 边界：设备、batch、序列长度和编译器决定收益，结论不跨硬件直接迁移。
- 待验证：同一安全模型在 CPU/GPU/NPU 上，unstructured、N:M、head/FFN、layer pruning 的 P50/P95、能耗和峰值内存交点是什么？

## G4：多模态安全 Token 剪枝已可行，但固定漏报风险与归因忠实度闭环仍缺失（满足 Motivation 门槛）

- 支持：SafeWatch 在会生成多标签判定和逐政策解释的视频 Guard 中直接使用 policy-aware visual-token pruning，并报告最高剪除 90% 视频 token 时平均性能下降小于 1%、同底座 SFT 4.6 s 到完整系统 3.9 s；VisionZip/SparseVLM 等通用 MLLM 工作独立证明视觉前缀、prefill 与 KV cache 存在冗余。
- 反证：SafeWatch 的 PR-95%/PR-99% 已出现明显 accuracy 与 explanation-rating 下降；通用复核又显示 attention selector 在定位任务和高压缩下可能严重失败。
- 边界：直接证据是视频审核，并结合 PEPE、PAP 和专门训练，不能外推为任意图文 Guard 的 training-free 剪枝结论；自然语言解释评分也不等于证据归因忠实。
- 待验证：在 fixed-FPR recall、worst-group recall、OCR/小目标/短事件/跨模态组合危害和 frame/region grounding 约束下，policy-aware、coverage-protected 与可逆检索各能达到多大安全预算？

## G5：平均 F1/AUPRC 不足以决定生产阈值（候选缺口）

- 支持：Llama Guard 3-1B-INT4 同时报告 F1 与 FPR；安全部署通常对漏报和误杀有不同成本；SafeRoute 还引入路由器第二个决策阈值。
- 反证：AUPRC 和 F1 对类不平衡仍比 accuracy 更合适，已有论文并非只报 accuracy。
- 边界：阈值需求依具体政策和人审资源而定。
- 待验证：压缩是否改变校准、rare-class recall 和选择性风险；能否以 risk-coverage curve 联合选择学生阈值与回退阈值？

## G6：On-policy 蒸馏尚未在可生成归因的多模态 Guard 上建立安全—成本闭环（候选缺口）

- 支持：GKD、MiniLLM、DistiLLM、Prefix OPD 与 Veto 分别覆盖学生 rollout、散度稳定和长轨迹成本；OPSA 直接进入安全对齐，但研究对象不是独立 Guard；SafeWatch 是可生成解释的多模态 Guard，却没有比较 on-policy 与静态蒸馏。
- 反证：OPSA 已说明安全场景可以利用特权安全上下文进行学生 rollout 自蒸馏；因此不能声称“安全 OPD 完全空白”。
- 边界：本轮检索不能证明不存在未收录预印本；通用生成和安全对齐证据不能直接外推到固定 FPR 的判别器。
- 待验证：在相同 teacher-token 预算下，风险条件 OPD 是否优于静态 KD 和学生错误驱动造数，并同时改善 fixed-FPR/worst-group recall、校准、解释忠实度与 time-to-verdict？
- 状态：只有一条直接安全预印本证据且没有本地基线，暂不升级到 Motivation。

## G7：压缩 Guard 的“计算预算—可判别攻击”边界尚未被系统刻画（满足 Motivation 门槛）

- 支持：Controlled-Release Prompting 直接利用轻量输入过滤器与目标 LLM 的计算不对称，并在 14 个开放 Guard 上验证；The Attacker Moves Second 独立表明，12 个近期防御在强自适应评估下多数可被以超过 90% ASR 绕过。两者共同否定“平均基准精度保持即可证明安全保持”。
- 补充证据：Sentinel/MTK 表明多层动态信号能提高自适应鲁棒性，但依赖宿主白盒状态；HarmAug/Llama Guard 1B-INT4 表明小 Guard 可以很强，却未消除资源受限对手专门构造难例的风险。
- 反证：不存在“小模型必然不安全”的结论；任务专用 encoder、级联和宿主表征复用可在部分数据上达到或超过大 Guard。
- 边界：该缺口针对对手知道或可查询 Guard、且目标模型能力显著高于 Guard 的部署；普通非对抗内容审核不受理论式最坏情况完全支配。
- 待验证：在固定总算力、固定 FPR 和固定回退率下，Guard 容量、输入复杂度、攻击计算预算、time-to-verdict 与自适应 ASR 的 Pareto 前沿是什么？何时应升级到大 Guard、宿主内部信号或人工复核？
