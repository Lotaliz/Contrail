---
id: multimodal-compositional-safety-gaps
type: synthesis
tags: [research, multimodal-safety, safety-evaluation, safety-alignment, safety-guardrail]
project_id: multimodal-compositional-safety
sources: [paper-wang-2024-siuo, paper-rottger-2025-msts, paper-palaskar-2025-vlsu, paper-zhou-2024-multimodal-situational-safety, paper-singguard-team-2026-singguard, paper-huang-2025-llavashield, paper-wang-2026-safeatlas-vl]
status: active
created: 2026-09-20
updated: 2026-09-21
title: "图文联合内容风险的研究缺口"
---

# 图文联合内容风险的研究缺口

## G1：严格联合必要性缺少统一验证协议

很多数据只说明图文相关，或某一模态没有显式敏感词，并未证明两个模态在相同政策下各自安全且任一缺失都会改变标签。现有 strict 数据集规模又较小或由模板/模型合成。

**可证伪问题：** 对每条样本独立完成人工 $y_I$、$y_T$、$y_{I\oplus T}$ 标注，并要求至少一个共享图和一个共享文的标签翻转反事实后，现有 benchmark 的 strict 有效率还有多少？

## G2：任务模型与 Guard 缺少同一套端到端评测

SIUO 侧重任务模型生成，MSTS 同时看回复审核，VLSU 侧重安全分类，SingGuard 侧重专用 Guard。不同论文的样本、政策、任务目标和指标不一致，无法计算“任务模型先失败、Guard 再漏检”的真实系统风险。

**可证伪问题：** 在同一 strict 数据上，分别测输入 Guard、任务模型、输出 Guard 和完整级联；端到端漏报是否等于组件独立错误乘积，还是错误高度相关？

## G3：缺少专用 Guard 的三路因果消融

用户提出的“联合输入使安全判别精度显著下降”需要在同一个 Guard 上比较 image-only、text-only、joint，并避免不同任务标签造成伪差。VLSU 做了三路输入，但主测通用 VLM；MSTS 测专用 Guard，但主要是图文语境下的回复审核。

**可证伪问题：** 在严格三标签数据上，专用 Guard 是否出现 $F1(I\oplus T)<\min(F1(I),F1(T))$，或在单模态均正确的样本中仍高频联合误判？

## G4：现有对齐数据可能学到模态极性捷径

如果训练集中的 unsafe 样本总有危险物体、OCR 有害词或明显攻击模板，模型无需学习关系。即使总体 ASR 下降，也不能说明 strict 组合被修复。

**可证伪问题：** 控制危险词、物体类别、图片来源和生成器风格后，仅加入配对 strict 样本是否仍提升跨模板、跨类别和真实图片泛化？

## G5：合成数据与评测同源性

SingGuard 展示了 strict 定向训练的积极结果，但训练和自建 benchmark 都依赖政策词表、自动生成和多模型过滤。生成器、模板或规则表同源可能使提升高估。

**可证伪问题：** 按生成器、图像来源、政策类别和提示模板做 group-disjoint 划分，并在 SIUO/MSTS/VLSU 的人工样本上独立测试，收益能保留多少？

## G6：安全与帮助性没有被统一建模

拒绝所有模糊输入会提高部分安全指标。MSTS 的 safe-by-accident 和 VLSU 的 borderline 分析已说明模型可能因没看懂而“安全”，或对教育、医疗、艺术语境过度阻断。

**可证伪问题：** 在固定 unsafe recall 下，strict 定向训练是否提高有效安全回应，而不提高 benign-sensitive/borderline 的拒答率？

## G7：现实分布覆盖不足

现有 strict 样本以英语、单轮、单图、静态政策为主。真实系统还包括多语言文化语境、多张图、视频时间关系、工具调用和具身行动；这些场景的组合空间增长更快。

**可证伪问题：** 单轮 strict 对齐能否迁移到跨轮线索累积、视频前后因果和图文—工具三模态风险？

## G8：修复 strict 漏洞时的既有能力退化

直接加入 strict 数据可能通过提高整体 unsafe prior 或扩大拒绝边界改善召回，却损害普通良性、政策例外和显式风险类别的校准。现有工作很少把“strict 提升”与“legacy 非劣”写成同一个约束问题。

**可证伪问题：** 在测试前设定非劣 margin，并在相同阈值与 matched-FPR 下比较，组合风险 residual 是否能提高外部 strict recall，同时维持标准多模态安全基准、benign-sensitive 和政策例外子群？

## G9：漏洞的部署可利用性与自适应性

benchmark 误判不自动等于安全漏洞。安全顶会需要证明攻击者可以在明确能力和查询预算下，让输入 Guard 放行、任务模型产生 harmful assistance，或让输出 Guard 再次漏检。

**可证伪问题：** 组合式样本能否跨 Guard 迁移，并在释义、替图、关系重排和针对防御重新构造后保持端到端逃逸；若只在固定模板上成立，研究应降级为数据诊断。

## 优先级建议

1. **先做 G1 + G3：** 建立可审计 strict 三标签与专业 Guard 三路消融，直接回答漏洞是否成立。
2. **再做 G2 + G9：** 把组件错误与端到端系统逃逸连起来，验证安全顶会所需的可利用性。
3. **随后做 G4 + G5 + G8：** 排除数据捷径、验证外部泛化和 legacy 非劣，再扩展 G6–G7。
