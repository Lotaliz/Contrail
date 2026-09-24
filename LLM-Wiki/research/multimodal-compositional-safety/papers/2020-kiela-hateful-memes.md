---
id: note-2020-kiela-hateful-memes
type: paper-note
title: "The Hateful Memes Challenge: Detecting Hate Speech in Multimodal Memes"
tags: [paper-note, research, multimodal-safety, content-moderation, safety-evaluation, vision-language-model]
source_id: paper-kiela-2020-hateful-memes
reading_level: skimmed
verification: source-checked
status: active
created: 2026-09-20
updated: 2026-09-20
---

# The Hateful Memes Challenge

来源：[arXiv v3](https://arxiv.org/abs/2005.04790v3)。核验摘要、基准动机与主要结果；未复现。

## 核心贡献

论文在多模态仇恨内容审核中加入 benign confounders：让文本或图片单独看与某些有害样本相似，但联合标签相反，从而使只依赖单模态快捷特征的分类器失败。论文报告当时最优方法准确率 64.73%，人类为 84.7%。

## 与组合安全的关系

这是“联合内容风险”早于生成式 LVLM 安全对齐的直接先例，说明内容审核社区已认识到图文关系可以改变有害性。它的重要方法遗产是**配对反事实/良性混淆项**，比简单收集更多正例更能检验真正联合理解。

## 边界

任务是静态梗图二分类，并不直接测试任务模型输出、拒答或通用安全政策；也没有对所有样本给出独立 image/text/joint 三标签。因此不能把它等同于后来的 SIUO/VLSU，但可作为数据构造和判别研究的历史起点。

关联：[[LLM-Wiki/research/multimodal-compositional-safety/landscape.md]]。

