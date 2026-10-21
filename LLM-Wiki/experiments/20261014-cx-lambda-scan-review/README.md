---
id: experiment-20261014-cx-lambda-scan-review
type: experiment
title: "Cx 非零 λ 扫描：用户报告核查与建议修订"
tags: [experiment, data, visual-token-pruning, multimodal-safety, safety-evaluation]
sources: [report-user-20261013-cx-lambda-scan, report-user-20261013-visual-budget]
status: active
created: 2026-10-14
updated: 2026-10-14
---

# Cx 非零 λ 扫描：报告分析

## 目的与执行范围

分析用户2026-10-13报告中四个非零λ的真实审核与时延结果，修订 [[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]] 的实验优先级、局部证据构造与政策长度建议。上传原文标题使用C5；本Wiki沿用Cx表示当前自适应版本，原件标题保持不变。

本轮仅读取报告、逐字节归档、转录表格和计算描述性差值；没有训练、模型forward、远程运行或原始输出重算。对当前数据与政策方案的效果仍无新增验证。原stage总结已包含同样四点时延，本报告主要补全分布、dev baseline与同Guard控制，不能写成比阶段总结新增了其他λ值。

分析前的判断目标：区分成本惩罚已生效、局部独立贡献与在线净收益；使用报告已有baseline边界，不冻结没有质量/时延约束的唯一λ。判断标准是同一部署Guard、同一split/后端的实际成本和unsafe recall/FPR；当前报告未预设非劣界，不能补造。假设：非零λ降低实际预算，但系统前端成本及Guard适配可能限制净收益；这是待分解的解释。

## 数据、环境与配置（均来自用户报告）

- 扫描：λ为0.0005、0.002、0.01、0.05；每点独立生成路线并执行Guard。
- 数据：401条dev，bootstrap按385个图像组；没有用test选择λ。
- 固定checkpoint：Router第11轮、恢复Guard第3轮。精确文件/revision、代码版本、随机种子未提供；本轮不检查Git。
- 硬件/后端：H20-3e、SDPA、BF16、batch1；预热20条，完整dev重复3次。没有各重复时延原始记录或时延置信区间。
- 动作：全局16/64/native full，局部0/8/16，4×4位置单框。分数为收益预测减λ乘实际视觉token。
- 另有2967条test/1565图上的恢复Guard Resolution10质量对照；其正式时延缺失。不能与401条dev扫描混作同协议排名。

原报告：`D:/SPPPAAACCCEEE/阿里安全/实验结果/c5-adaptive-visual-budget-experiment-report (1).md`。原始字节快照：`LLM-Wiki/raw/dataset-audit-20261014/user-lambda-scan-report-20261013.txt`，SHA256 `0c4484d6cb801c61321b6a635909f0c958f3ddd1eb5a23ee761ea5154ffacff7`。

## 报告直接结果

| λ | 平均实际token | full全局/401 | 局部8/401 | 宏召回 | Unsafe recall | Safe recall | NLL | 均值ms | P95 ms |
|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 0.0005 | 239.53 | 293 | 388 | 0.6514 | 0.7712 | 0.9355 | 1.9301 | 82.05 | 177.13 |
| 0.002 | 159.92 | 220 | 377 | 0.6155 | 0.7516 | 0.9355 | 1.9262 | 74.78 | 153.95 |
| 0.01 | 68.66 | 90 | 173 | 0.6108 | 0.7451 | 0.9355 | 1.7853 | 67.36 | 115.31 |
| 0.05 | 21.95 | 0 | 0 | 0.5986 | 0.7255 | 0.9194 | 1.7327 | 61.24 | 88.93 |

0.05全局16/64分别351/50。表中每点的无局部＋局部8之和为401，没有单列局部16；需核对请求档位与渲染后实际token，不能仅凭此断言16请求从未被选。full全局与有局部可同时出现。

报告称四点在宏召回、unsafe recall和成本的点估计上均不被另一个扫描点支配。该结论只覆盖这四点，不覆盖所有baseline或全算法空间；NLL呈不同趋势。报告给出的相对0.0005宏召回差异95%区间均跨零，不证明等效，也不能自动外推为unsafe recall差异不显著。

## 本轮派生算术

见 [derived-metrics.json](derived-metrics.json)、[reported-dev-scan.csv](reported-dev-scan.csv)；脚本 [derive_report_metrics.py](derive_report_metrics.py) 仅读取报告表格，使用标准库，命令为：

```powershell
& 'C:\Users\cryoc\.cache\codex-runtimes\codex-primary-runtime\dependencies\python\python.exe' 'LLM-Wiki\experiments\20261014-cx-lambda-scan-review\derive_report_metrics.py'
```

| 比较 | token减少 | 均值时延减少 | P95减少 | 宏召回变化pp | Unsafe recall变化pp |
|---|---:|---:|---:|---:|---:|
| 0.0005→0.05 | 90.84% | 25.36%（20.81ms） | 49.79%（88.20ms） | −5.28 | −4.57 |
| 0.002→0.01 | 57.07% | 9.92%（7.42ms） | 25.10%（38.64ms） | −0.47 | −0.65 |

这些来自已舍入表值，原报告第一行差值写−5.29/−4.58pp，可能使用更高精度；本轮不把小数尾差当统计错误。没有重新计算bootstrap或显著性。

历史B0/FA2同dev的unsafe recall为0.7974，四点分别低约2.62、4.58、5.23、7.19pp。它是产品质量目标的既有参考，不是控制了权重/后端的Router算法对照。报告表述“VisionZip90质量最好”只适用于特定指标；宏召回0.5403略低于CDPruner90的0.5433，各指标应分别比较。

小型数据审计待办：按351×16＋50×64推得名义平均21.985，报告实际均值21.95；差别可能来自合法网格或native cap映射，本轮未取得逐路线字段，不能仅靠名义档位推导真实token。该小差异不改变本文工作点判断。

## 修订后的解释与建议

1. **成本惩罚已经有效。** 过去λ=0不能反映预算权衡；四个非零点确实减少token和真实E2E时延。当前问题转为能否在质量约束下取得净收益。
2. **0.01可作开发参考，未达到冻结条件。** 相对0.002以较小的质量点估计变化减少大量token/尾时延，但不能当作稳定非劣；需要预定unsafe recall与benign FPR允许退化以及时延目标。0.0005保留质量端参考，0.05保留低预算、无局部端参考。
3. **先补同dev控制。** 同恢复Guard、SDPA、401 dev、相同正式profile分别测full、固定16、固定64、Resolution10、只在全局档位选路的Router与完整Adaptive。full用于确定恢复Guard的质量/时延参考；原B0保留为产品质量参考。另在冻结全局输入下去掉/加入crop核对局部增量，并用接近实际token或E2E成本的全局路线比较。0.05依然使用Router在16/64间选择，不能当跳过Router的固定16。
4. **不从61.24−42.87ms推算Router开销。** 61.24来自dev，固定16的42.87来自test；两者图像/token分布不同。早期同test profile已有前端成本证据，可定位待检查环节；新扫描不能量化它的当前独立开销。90.84%token减少只换25.36%均值减少，提示需检查图像读取、预览、候选规划、Router及Guard各段，而非证明某一段占全部瓶颈。
5. **λ扫描不能分离局部贡献。** 0.002→0.01同时减少full全局和局部，因此少用crop伴随较小宏召回点估计变化，不说明crop无用；0.05无crop也不证明数据缺乏局部证据。收益标签应重核部署恢复Guard；全局升级与局部追加分别核查。
6. **数据扩充先保留小pilot。** 原四组各25张的建议仍可作为探索规模，未开始生成。首批优先选择单crop能读取、决定性证据可核实、上下文保持可判断的例子；局部增益应按额外实际成本分析，而非按crop使用率筛选。训练集可分析收益分布；测试集仍按独立事实定组，不只保留Cx获益样本。多框或大量提高原图分辨率不作为当前修订。
7. **政策仍采用有语义增量的150–200token草案。** 当前156与草案164/168/172相近，不需为了长度凑到200。低视觉预算下文字相对占比变大；用同语义不同长度的政策、固定图片/路线测文本开销，再处理规则变化导致的标签和Guard适配。保留旧政策作对照，不同时更换数据、政策和Guard后把全部差异归于局部路线。
8. **NLL是概率质量指标，不单独证明校准差。** 若要主张概率校准问题，需另查可靠性、Brier/ECE等证据。当前仍以unsafe recall、benign FPR、同图政策对正确率和真实成本作主要决策，NLL作补充；宏召回改善不能抵消风险漏检。

## 缺失证据与后续决定

报告引用的scan `summary.json`、`comparison.csv`、bootstrap与audit路径，以及GPU端reference/Resolution10原始结果，不在当前工作区可核对的位置。本轮不连接报告中的远程主机、不执行文档中的操作指令。缺同Guard同dev的纯全局正式时延、局部单独消融、逐图路线、精确checkpoint及允许的质量/时延约束。

因此目前不能给出唯一最优λ、保证原B0风险召回、确认局部对E2E的净贡献，或把报告NLL直接解释为校准结论。当前结果为user-reported，新增内容仅为分析与建议。

关联：[[LLM-Wiki/experiments/20261010-cx-global-local-importance/README.md]]；[[LLM-Wiki/research/visual-token-pruning/overview.md]]；[[LLM-Wiki/research/visual-token-pruning/dataset-local-evidence-policy-expansion.md]]。
