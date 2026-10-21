---
id: change-2026-10-21-selected-three-papers-deep-read
type: change
title: "完成QART、PAA-Bench与视觉充分性景观三篇已选论文精读"
tags: [change, research, visual-token-pruning, source]
date: 2026-10-21
change_type: Added
status: active
---

# 范围与交付

按用户已完成的筛选，只读取当前三篇selected。实际初始状态pending0、selected3、skipped91、deferred1、ingested30；页首的pending10是历史收集快照。本轮不改另外七篇skipped，不自动选择28篇备查，不重新检索或修改定时设置。

新建三篇deep-read / source-checked笔记：[[LLM-Wiki/research/visual-token-pruning/papers/2026-balaji-qart.md|QART]] / [[LLM-Wiki/research/visual-token-pruning/papers/2026-li-paa-bench.md|PAA-Bench]] / [[LLM-Wiki/research/visual-token-pruning/papers/2026-li-visual-sufficiency-landscapes.md|Visual Sufficiency Landscapes]]。读取QART正文§1–5/附录A–C、PAA正文§1–6/附录A–G、充分性景观正文§1–7/附录A–E，完整PDF分别23/35/31页。视觉核对各六页，共18页；关键公式、主表、效率与统计边界均定位到章节、图表或页码。未训练、运行作者代码或复现实验。

## 原件与获取缺口

五份原件HTTP200，下载后检查长度、文件尾、PDF逐页解析及SHA256；原件保持字节不变，只作本地副本，发布笔记使用官方URL。QART先前HTML请求一次SSL EOF、一次curl连接超时，未保存为raw；官方HTML经浏览工具可访问，完整PDF含附录，不影响精读范围。两份HTML完整闭合，三个PDF均无空解析页。

| arXiv / 格式 | 字节 | 页数 | SHA256 |
|---|---:|---:|---|
| 2610.22957v1 / pdf | 6603549 | 23 | `5e7d16093651bbb5c8c18322f916cf48bdc1825ef07421273eeb5d358d7f0fb5` |
| 2610.24740v1 / html | 648409 | — | `6e53253c9caf3d1175b8db1e541716241d01a49b07d5197ad083e2cbdd9e6785` |
| 2610.24740v1 / pdf | 15136705 | 35 | `788a6471780a3c6d969dcccd5f6092ab90e93b1af4611733623729ef5a06974a` |
| 2610.24968v1 / html | 399324 | — | `f10f6684b747ddfd3efbadd68a98db71efe4a2a0dccc329e5984b335517236b6` |
| 2610.24968v1 / pdf | 940125 | 31 | `e4108a99161a9c4541653fcfb8813772e5a60d351f43416dc7e80c0cc60a6d6e` |

QART/PAA论文为CC BY4.0，充分性景观为CC BY-NC-SA4.0，均据官方HTML记录；代码仓库许可不代替论文许可。原三个source_id保持，题录与初筛历史保留，不新增重复来源。具体获取UTC时刻保存在来源notes。

## 研究判断与证据边界

当前项目已改为政策条件整图分辨率选择，论文只提供机制、评价和离线测量参考；未恢复被删的Cx/单框方案。QART低token数量不保证单请求加速；PAA保留原有正确性不应抹去真实纠正；充分性景观可能保留错误、晚层前缀已有视觉信息，且不是免费的在线估计器。

PAA图2的LLaVA预算与附录C.3不同、表12与E.3关于最高速度不一致，笔记保留差异；未擅自修正作者实验。充分性景观的小队列、区间跨零、pilot与新图设计、定位失败和单token特征缺失均说明。QART区域监督、任务适配、长政策文本与计时配置披露缺口均保留。

## 文件改动与收尾

- 新建：上述三篇papers笔记与本记录；五份本地原件。
- 修改：raw/sources.yaml、项目overview.md、reading-log.md、comparison.md、watch/candidates.md、watch/overview.md、CHANGELOG.md。
- 保留：全部294个候选ID、相关备查与排除表、既有人工决定、来源ID、原件与旧笔记；不改研究方案、motivation、concept、实验或插件。
- 首次wiki-finalize PASS后已晋升三篇；候选当前pending0、selected0、skipped91、deferred1、ingested33。基线及首次均0错误、2项既有警告；首次及晋升后Wiki校验均PASS，0错误、2项既有警告（旧实验README断链、2026-08-25记录缺少CHANGELOG入口）；本轮未新增警告。另核对原件哈希、来源唯一、294个候选ID、33篇ingested层级及其他人工决定。
- 全程不调用Git。
