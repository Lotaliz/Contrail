---
id: change-2026-09-08-safety-sufficient-vision-prefix
type: change
title: "将视觉 Token 剪枝方案收束为安全充分视觉前缀训练"
tags: [metadata, research, visual-token-pruning]
date: 2026-09-08
change_type: Changed
---

# 本次语义与结构变化

- 针对“缩短视觉编码器、encoder 前早剪、合成剪枝样本再训练”完成直接最近邻排重；新增 EfficientVLM、Patch Slimming、METR、FastVLM、Dyna-ViT、QuietPrune、ResponseGuard 和 SAP 共 8 条来源及 8 篇 paper-note。
- 覆盖更新 visual-token-pruning 的 landscape、comparison、gaps、motivation、reading-log 与 overview；主方案新增 §21，将三项策略收束为政策因果安全充分视觉前缀（PC-SVP）、最坏压缩格训练（WCST）和压缩翻转反事实回放（CFR）。
- 将全局底图+稀疏高清残差（GCR）降为第二阶段高风险组件；把简单截层蒸馏、多出口 early pressure、query-guided early pruning 和普通剪枝样本 SFT 明确为强基线。
- 推荐先执行不需要 selector/router/serving 的 E0：固定完整输入下比较截层无训练、普通安全 SFT、logit KD、METR 式多出口与 PC-SVP；仅在浅前缀机制成立后加入输入早剪。
- 更新研究入口、首页描述、标签论文数与受影响标签计数；不新增标签或 document type，不修改 raw 原件与实验输出。

# 证据与未决事项

- PC-SVP、WCST、CFR 和 GCR 均为待验证 hypothesis；本轮没有运行训练或时延实验，也不声称首次提出任何单个组成原语。
- ResponseGuard 对冻结视觉编码器的解释没有解冻消融；SAP 的会议状态与结果本轮依据作者官方仓库，论文正文链接未取得。两项边界已在笔记中保留。
- 正式新颖性取决于政策/像素干预监督是否超过 METR/KD、压缩格尾部训练是否泛化到未见状态，以及 fixed-FPR worst-group recall—time-to-verdict 是否形成更优前沿。

# 收尾范围

本记录只描述当前任务的实际 Wiki 变化。未执行任何 Git 操作；旧实验、失败记录、用户笔记和不相关页面均保留。

