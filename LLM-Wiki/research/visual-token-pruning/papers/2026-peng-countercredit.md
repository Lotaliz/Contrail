---
id: note-2026-peng-countercredit
type: paper-note
title: "When Should a VLM Look? Paying Only for Visual Calls That Were Needed and Used"
authors: [Kunyu Peng, Junming Liu, Ruiqi He, Qingzhuo Wang, Jianzhong Qi, Xianhui Liu]
year: 2026
venue: arXiv
source_id: paper-arxiv-2609-22910
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: medium
priority: high
tags: [paper-note, research, vision-language-model, multimodal-agent, visual-evidence]
status: active
created: 2026-09-24
updated: 2026-09-24
---

# CounterCredit：为真正必要且被使用的视觉调用计价

## 书目信息与阅读边界

来源：[arXiv 2609.22910v1](https://arxiv.org/abs/2609.22910)，首次提交于 2026-09-19，许可为 CC BY 4.0。精读 30 页 PDF 的正文、算法与证明边界、主表 1–4、附录中的奖励审计、敏感性和完整表格；本地原件：[[LLM-Wiki/raw/papers/2609.22910v1.pdf]]。未运行 RL、模型或工具环境；结果均为作者报告。

本文不做内部视觉 token 剪枝，而是训练会 crop/zoom 的 VLM agent 只在视觉调用“确有必要且返回像素确被使用”时获得奖励，因此属于视觉证据预算与因果核验的 adjacent 工作。用户从近期索引选中后，复用 `paper-arxiv-2609-22910` 完成精读。

## 问题定义

轨迹最终答对不能证明中间视觉调用有价值：模型可能在调用前已能作答，也可能因为“进行了调用/进入回答状态”而改变输出，返回像素并未真正影响决策。作者把任一条件失败的调用称为 spurious。冷启动 checkpoint 只有约 10%–12% 的调用同时满足必要与使用；若按各 agent 自己的 gold-answer scorer 审计，已发布 agent 在单个 benchmark 上有 36%–87% 的调用为 spurious。

CounterCredit 对每个已执行 crop 固定其真实 pre-call prefix $h_i$，构造三条 continuation：立即回答、原调用加真实 crop、原调用加同图同尺寸随机 patch。多选题的效用 $U_\theta$ 是 gold option 在选项集合内重归一化的概率；自由回答用参考答案逐 token 平均 log-probability。probe 用当前 policy 计算并 stop-gradient。

## 两个反事实量

决策价值比较真实视觉分支与立即回答：

$$
D_i=U_i^{real}-U_i^{now}.
$$

证据价值比较真实 crop 与 $K$ 个随机同尺寸 patch 的均值：

$$
E_i=U_i^{real}-\frac1K\sum_{k=1}^{K}U_\theta(h_i,c_i,\widetilde o_{ik}).
$$

$D_i>0$ 表示“看一下”相对立即回答有帮助，$E_i>0$ 表示帮助来自返回像素。两轴给出四类：两者都正为 real；只有 $D$ 为正是 performative；只有 $E$ 为正是 unnecessary；两者都不正为 waste。论文用 $q_i=\min(E_i,D_i)$ 作为同时超过两种 reference 的保守优势；这是一种基于 policy 自身 answer score 的操作化定义，不等于人类因果判断。

## Cashback、rent 与双通道 GRPO

只有正确轨迹、probe 合格且 $q_i>\epsilon$ 的调用被验证。已验证调用免租并按超出 deadzone 的幅度获 cashback，其他已执行调用每个支付 $\rho$：

$$
P(\tau)=\min\left(C,\gamma\sum_{i\in V(\tau)}(q_i-\epsilon)\right)-\rho[n(\tau)-|V(\tau)|],
\quad R(\tau)=r_{out}(\tau)+P(\tau).
$$

默认 $\rho=0.05,n_{max}=6,C=0.7,K=3$。当 $\rho n_{max}<1$ 时，作者证明所有正确轨迹的奖励仍高于错误轨迹；该保证只维护 reward ordering，不保证测试准确率或工具策略最优。rent 还用于抵消有限随机 patch 导致的偶然过阈值。

标准 GRPO 对总 reward 做组内归一化，会使 rent 的有效尺度随组内 outcome 组成变化。作者把 outcome 标准化、price 只中心化：

$$
\widehat A_j=\frac{O_j-\overline O_{g(j)}}{\max(\operatorname{std}(O_{g(j)}),\sigma_{min})}+P_j-\overline P_{g(j)},
$$

其中 $\sigma_{min}=0.15$。每个正确轨迹的合格调用需要 $K+2$ 次额外 score evaluation，训练成本随调用数线性增加。

## 实验结果

四个感知 benchmark 为 V*、HR-Bench-4K/8K、MME-RealWorld，另测 MMStar、ChartQA、BLINK。主模型从 Qwen2.5-VL-7B 冷启动，另验证 Qwen3-VL-8B；与 outcome-only、TACO 式 branch reward 及多个公开视觉 agent 对比。

CounterCredit 在 V*/HR-4K/HR-8K 为 89.5/80.2/76.4，比同冷启动、同 prompt pool 和预算的 outcome-only GRPO 高 9.4/6.3/7.0 点；七任务平均 76.1，对 outcome-only 的 68.9。V* 的调用数为 1.78 vs 1.84，但 spurious rate 从 82.1% 降到 31.4%，说明收益来自调用质量而非单纯减少数量。相对发布版 Mini-o3，V* 为 89.5 vs 87.4，调用 1.78 vs 2.50，spurious 31.4% vs 40.7%；跨 agent 的工具、prompt 和交互格式不同，因此只有 matched reward ablation 支持较强归因。

在 H20、vLLM、batch 1 上，CounterCredit 三个分辨率 benchmark 的每题时延为 5.4/8.8/10.0 s；不是最低，但处于准确率—时延前沿。Qwen3-VL-8B 的四个感知任务平均从 75.4 提到 80.8，但该 backbone 未做完整奖励消融。

消融表明只验证 $E$ 或只验证 $D$ 的七任务平均为 69.4/71.3，TACO 式 branch reward 为 71.6；去掉 cashback/rent 为 70.0/73.1；单通道 GRPO 为 64.5。第一调用干预中，CounterCredit 的真实 crop 相对立即回答/随机 patch 的准确率差为 6.8/11.0 点，而两个基线接近零或为负；小目标 tercile 相对 outcome-only 的提升最大（15.8 点）。

## 局限与项目关系

作者明确列出三点边界：$D$ 无法分离 crop 决策本身与回答 elicitation 的影响；$E$ 目前只适用于有同图同尺寸 null return 的 crop；spurious 指标正是由训练中的两个 contrast 构成，需要独立于奖励的外部效率评价。

此外，随机 patch 可能偶然包含目标或改变低层统计，$K=3$ 的估计噪声仍存在；score 基于 policy 自身概率，校准偏差会影响标签；训练 probe 成本较高；实验只覆盖单一 crop 工具，没有内部 token、区域组合或安全判别。

对当前项目最有价值的是把“政策条件下的视觉证据被选中”升级为两个可检验问题：没有这些 token 时判定是否已成立，以及用匹配无关视觉替换时输出是否改变。可把 $D/E$ 思路迁移为离线 token/区域干预审计，但不能直接把 crop-call reward 当作 token-pruning loss；需要定义与位置、面积、纹理匹配的 token-level null，并用独立 unsafe recall/FPR 验证。

## 证据定位与待验证项

- 三 continuation、gold score 与调用分类：§3.1–3.4，图 2–3，式 (1)–(6)。
- outcome dominance、chance verification 与双通道 GRPO：命题 1–4、§3.5、附录 A/C。
- 主结果、调用/时延/spurious：表 1–2、§4.2。
- 奖励审计与消融：表 3–4、图 4–5、§4.3–4.4、附录 F。
- 限制：§5；TODO：token-level matched null、独立 evidence-use metric、政策翻转与 Guard 错误类型、训练开销复现。本轮均未执行。
