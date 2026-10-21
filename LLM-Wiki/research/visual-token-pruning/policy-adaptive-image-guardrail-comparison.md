---
id: policy-adaptive-image-guardrail-comparison
type: synthesis
title: "SafeGuard-VL 与 PolicyShiftGuard：Policy-Adaptive Image Guardrail 定义、方法与边界"
tags: [research, safety-guardrail, multimodal-safety, safety-evaluation, vision-language-model]
project_id: visual-token-pruning
sources: [paper-piao-2026-policy-adaptive-image-guardrail, paper-song-2026-policyshiftguard, repository-safeguard-vl, model-safeguard-vl-rl, dataset-safeeditbench, repository-policyshiftguard, model-policyshiftguard-3b, dataset-policyshiftbench]
status: active
created: 2026-09-22
updated: 2026-10-20
---

# SafeGuard-VL 与 PolicyShiftGuard：Policy-Adaptive Image Guardrail 定义、方法与边界

> 本页保留 2026-09-22 的论文比较与当时长政策路线判断；现行短政策视觉剪枝方案见 [[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]。

## 核心结论

两篇工作形成清楚的递进关系：

- **SafeGuard-VL** 首先把问题从固定图像安全分类提升为 `(image, natural-language policy) -> verdict`，重点解决单政策 SFT 的跨政策过拟合和通用能力遗忘。
- **PolicyShiftGuard** 进一步指出跨 benchmark F1 仍可能只是在识别“看起来危险”的图像，于是把适应性收紧为**同图政策翻转**，并在数据、损失和指标三处显式编码这个反事实。

因此，SafeGuard-VL 更像“policy-conditioned generalization”；PolicyShiftGuard 更接近“policy-causal decision boundary”。后者的定义更适合作为长政策压缩 Guard 的主任务。

## 统一形式化

固定 taxonomy Guard 隐含假设：

$$
y=g(I).
$$

两篇都改为：

$$
y=g(I,P).
$$

SafeGuard-VL 主要通过五个政策下的跨政策性能验证 $P$ 被使用。PolicyShiftGuard 则显式加入视觉属性中介：

$$
A=h(I),\qquad y=\bigvee_c f_{c,P_c}(A_c).
$$

同一 $A$ 不变，只替换 $P_c$，若规则边界改变则 $y$ 必须翻转。这一区分使“政策适应”从相关性要求升级为配对反事实要求。

## 逐项比较

| 维度 | SafeGuard-VL / SafeEditBench | PolicyShiftGuard / PolicyShiftBench |
|---|---|---|
| 主要失败定义 | 单政策 SFT 过拟合训练政策/模板，并损失通用能力 | 模型依赖图像级风险先验，不随运行时政策边界改变 verdict |
| 政策结构 | 五个全局 L1–L5 政策，含反常的宽松/严格定义 | 七类风险 × 现实场景形成 28 个政策；运行时组合成 bundle |
| 图像控制 | unsafe 图像与局部编辑 safe counterpart | 同一图像、同一属性记录、多个 policy prompt |
| 标签来源 | 五政策下人工 safe/unsafe 标注 | VLM 投票得到原子属性，再执行确定性政策规则 |
| 训练 Stage 1 | 100K 图像的有害细节 recaption SFT，先学视觉语义 | 随机顺序/ID/槽位的 policy SFT，先学政策接口与短输出 |
| 训练 Stage 2 | GRPO/RLVR，用 safe/unsafe 标签作政策奖励 | 同图 pass/block 边界对 + pairwise margin |
| 输出 | 判定并鼓励政策解释 | `false` 或 `true | category`，通常五 token 内 |
| 核心指标 | 各政策 F1；L1 用 accuracy；再宏平均 | Acc/F1 + PSS；PSS 要求政策翻转两侧都正确 |
| 泛化切分 | 单一政策训练、跨五政策测试；多个外部 benchmark | Adaptive policy families 与 12 个 held-out Shift policies |
| 主要贡献 | 暴露跨政策和能力保持问题；语义学习与政策判定解耦 | 可审计规则数据、严格 flip metric、直接优化政策边界 |

## 两种“感知—政策解耦”路线

SafeGuard-VL 在模型训练中隐式解耦：Stage 1 让模型描述有害元素，Stage 2 再判断政策是否允许。它依赖模型内部学出稳定视觉语义，优势是可覆盖开放视觉描述；缺点是中间语义不可审计，RL 标签也不能证明 rationale 忠实。

PolicyShiftGuard 在数据生成中显式解耦：先定义并投票原子属性，再以可执行政策规则生成标签。优势是每次翻转可追溯到属性和规则；缺点是属性集合和规则 schema 是 closed-world，现实政策中未枚举的事实和模糊冲突会被漏掉。

对当前课题，二者可以组合：用 SafeGuard-VL 式 open-ended semantic teacher 补充开放视觉事实，用 PolicyShiftGuard 的结构化条款和边界对约束最终 verdict。

## 它们是否“解决”了 policy adaptation

### SafeGuard-VL：部分解决

它较强地缓解了安全专门化导致的外部 benchmark 和通用能力退化；但自身 SafeEditBench 表 6 中，RL+SafeEditTrain 总分 49.43，仅小幅高于未专门训练 Qwen2.5-VL-7B 的 48.68。PolicyShiftBench 上 SafeGuard-VL-RL 的 F1 51.0、PSS 4.0，说明其风险识别可以，但同图政策翻转仍很弱。

### PolicyShiftGuard：在其封闭 schema 内明显解决

PolicyShiftGuard-7B 作者报告 Avg. F1/PSS 76.9/72.1；pair loss 消融使 7B Avg. F1 下降 17.7 点。证据支持 matched boundary pairs 确实比普通额外 SFT 更有效。然而结论只覆盖英文、结构化、有限类别/属性和静态图像；论文明确不覆盖长用户自定义或法律文档式政策。

## 对长政策联合压缩的直接启示

### 1. 任务定义采用 PolicyShiftGuard，而非普通宏 F1

政策压缩器 $C$ 不仅要保持同一政策下的判定，还要保持真正的政策差异：

$$
g(I,P)=g(I,C(P,I)),
$$

并且当 $P^+$ 与 $P^-$ 跨越规则边界时：

$$
g(I,C(P^+,I))\neq g(I,C(P^-,I)).
$$

因此需要同时报告 full-vs-compressed 一致性、PSS、unsafe recall at fixed benign FPR 和 unsafe-to-safe compression flip。

### 2. 政策编译应按条款而不是 BPE token

PolicyShiftGuard 的 `attribute -> executable rule -> verdict` 为 policy compiler 提供了天然教师。必须保护触发属性、否定、豁免、作用域和跨类别 OR；普通 attention Top-k 很可能删除短但决定性的 exception。

### 3. 训练应使用“双重反事实”

- 固定图像，换政策：要求该翻转时必须翻转；
- 固定图像和政策语义，换完整/压缩表达：不该翻转时必须保持。

前者来自 BP-Adapt，后者是当前长政策压缩课题需要新增的贡献。

### 4. 数据分工

- PolicyShiftBench：主评测/训练骨架，提供同图翻转、规则和 PSS；
- SafeEditBench：外部视觉近邻压力测试，检查局部视觉证据是否被 patch pruning 删除；
- 不新增安全标签的派生视图：从现有完整 policy bundle 确定性地产生条款切分、token 预算和压缩版本，用于训练 selector 和测量 length-risk 曲线。这属于实验预处理，不应被表述为一个新安全数据集。

## 公开工件与直接复用边界

| 工件 | 可直接使用的内容 | 规模/状态 | 对当前课题的角色 |
|---|---|---|---|
| [PolicyShiftGuard-3B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-3B) | 最终 RP-SFT + BP-Adapt 权重，可由 Transformers/vLLM/SGLang 直接加载 | Qwen2.5-VL-3B 基座；Hugging Face 计为约 4B 总参数，BF16 仓库 7.53 GB | 首选学生、主基线和 full-token teacher |
| [PolicyShiftGuard-3B-RP-SFT](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-3B-RP-SFT) | Stage-1 中间权重 | 同一 3B 级基座；非最终模型 | 分离“普通政策 SFT”与“边界适配”的消融 |
| [PolicyShiftGuard-7B](https://huggingface.co/PolicyShiftGuard/PolicyShiftGuard-7B) | 最终权重 | Qwen2.5-VL-7B 基座；Hugging Face 计为约 8B 总参数 | 大模型 teacher/尺度验证，不建议作为首个开发基座 |
| [SafeGuard-VL-RL](https://huggingface.co/tyodd/SafeGuard-VL-RL) | 可直接推理的完整权重 | Qwen2.5-VL-7B 级，BF16 仓库 16.6 GB | 跨方法外部验证；不是小模型 |

SafeGuard-VL 的公开权重需要特别谨慎解释：模型卡明确说明它只做了 Stage-2 GRPO，**没有**论文完整方法中的 Stage-1 unsafe-semantic SFT。因此它可复用为 `SafeGuard-VL-RL` 基线，但不能当作 `SafeGuard-VL-Full` 的公开复现。Hugging Face 页面显示的 `849k params` 与 Qwen2.5-VL-7B 基座和 16.6 GB 权重分片矛盾，应视为元数据异常而不是模型规模。

[PolicyShiftBench 公共包](https://huggingface.co/datasets/PolicyShiftGuard/PolicyShiftBench)已经给出 RP-SFT、BP-Adapt boundary pairs、Adaptive/Shift 评测、可执行规则和政策释义，足以避免重新采集/标注主数据；但其条款是非商业研究许可。[SafeEditBench](https://huggingface.co/datasets/tyodd/SafeEditBench)给出完整政策文本、901 张训练图、128 张测试图和 601 个测试实例，采用 CC BY 4.0，同时需要同意研究用途的 gated access。

## “无需重新训练”的准确结论

可避免的是：新收集图片、重新定义安全 taxonomy、重新人工标注，以及从基座模型开始做完整 guard 对齐。不能预先假设可以避免的是**压缩感知适配**。

- 完全冻结模型、只做 attention/similarity Top-k，可以作为 training-free 基线；它能回答现成 Guard 在联合压缩下自然有多稳。
- “视觉指导政策选择、政策指导视觉选择”会引入新的 selector、压缩后的序列分布和跨模态依赖。若不训练这些模块，难以同时保持 PSS、否定/例外和局部视觉证据。
- 推荐冻结大部分 Guard，只训练 policy-clause selector、visual-patch selector 和少量 LoRA；监督直接来自现有标签、boundary pair 和 full-token teacher，不需要新人工标注。
- 最终论文应比较 `training-free`、`selector-only`、`selector + LoRA` 三档，实证决定最小训练量，而不是把“零训练”写成方法前提。

## 迁移到其他架构

功能上可以迁移，但目前公开证据只验证了 Qwen2.5-VL-3B/7B。PolicyShiftGuard 的核心监督是 `(image, policy bundle) -> structured verdict`、随机化政策接口和同图 boundary-pair loss，原则上不依赖某个专属 Qwen layer；迁移到另一可训练 VLM 时，仍需重做 prompt/processor、视觉 token hook、输出解析，并进行 SFT 与 boundary-pair adaptation。SafeGuard-VL 的 GRPO 也可原则性迁移到支持 rollout、log-probability 和视觉输入的 VLM，但 Stage-1 recaption 与 Stage-2 RL 成本更高，且官方发布没有给出跨架构结果。

因此“获得同样功能”应被写成**待验证的可迁移假设**，不能由训练脚本接受 `model_name_or_path` 推导出来。最低复现条件包括未见政策切分、PSS、结构化输出正确率、完整/压缩输入一致性和跨 benchmark 验证。

## 尚未被两篇解决的研究空白

两篇都没有研究政策 token 长度的系统成本、政策缓存/编译、条款选择、视觉—政策 token 协同预算，或压缩后的安全非劣。PolicyShiftGuard 甚至明确把 long user-defined policies 列为未来工作。因此，当前路线不应重复“再做一个 policy-adaptive Guard”，而应把贡献放在：**在更严格的同图 policy-flip 定义下，实现可审计的长政策压缩与视觉证据协同选择。**

关联：[[LLM-Wiki/research/visual-token-pruning/policy-guided-resolution-selection-research-plan.md|当前研究计划]]；[[LLM-Wiki/changes/2026-09-24-cleanup-unread-raw-and-superseded-plans.md|历史方案清理记录]]。
