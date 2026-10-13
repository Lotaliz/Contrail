---
id: note-2026-han-foveated-compression
type: paper-note
title: "Foveated Compression: Selective High-Resolution Preservation for Token-Efficient VLMs"
authors: [Donghyun Han, Jangho Park, Yuseok Bae]
year: 2026
venue: arXiv
source_id: paper-arxiv-2610-07729
project: visual-token-pruning
reading_level: deep-read
verification: source-checked
relevance: high
priority: high
tags: [paper-note, research, visual-token-pruning, vision-language-model, efficient-inference, knowledge-distillation]
status: active
created: 2026-10-10
updated: 2026-10-13
---

# Foveated Compression：单高清区域的干预监督与选择失败

## 原件与阅读范围

[arXiv 2610.07729v1](https://arxiv.org/abs/2610.07729v1)，CC BY-NC-ND 4.0；完整原件见 [HTML 原文](https://arxiv.org/html/2610.07729v1)。精读 §1–5、式 1–6、表 1–2、附录 A–D 的训练/预算/统计/失败分析。未执行训练或本地复现，以下数字均为作者报告。

## 一次完整编码后的粗细替换

§3.1–3.2：Qwen2.5-VL-7B-Instruct 完全冻结，先做完整分辨率 ViT。新增32.77M参数的 merger 对 $3\times3$ patch feature 做 mean pooling 加 residual MLP，再通过冻结的 Qwen native $2\times2$ merger；整体对应一个压缩 token 覆盖九个 native token。residual head零初始化，初始为均值池化，统一压缩序列为原来的1/9。

§3.3–3.4：图像另划为九个等面积 coarse cell，10.8M参数 selector 选 **恰好一个** cell，其压缩单元原地替换为已有 native token。无需再编码，但不是从原像素新裁图，也不降低前端 ViT 成本。混合输入为 $N_{mix}=N/9+8N/81=17N/81$，即20.99%。native token沿用坐标，压缩 token用对应块左上角，其他视觉和文本位置不随区域选择移动。输入252像素对齐保证各级划分严密。

selector 描述子包含 native均值、压缩feature、两者差和坐标；问题embedding最多48token，经self-attention，再由视觉query做8头cross-attention，depthwise卷积与MLP输出分数；cell分数是其单元平均。架构允许问题条件，但实验没有证明问题内容有效。

## 训练标签：真实路线结果与并列赢家

merger在GQA/TextVQA/DocVQA/InfoVQA/ChartQA/ScienceQA训练，teacher greedy答案固定，student teacher-forcing，对下一词分布做KL；附录A缓存79,723样本的top-256概率，一epoch、2378steps，8×RTX A5000，作者报告merger约6.9 GPU-hours。

merger冻结后对每训练样本执行九个同预算动作，按实际答案任务分数取赢家集 $\mathcal W$；all-nine tie删去，部分并列保留，用 $-\log\left(\sum_{c\in\mathcal W}e^{s_c}/\sum_je^{s_j}\right)$ 训练四epoch。标签生成约18.1 GPU-hours。按image-group划分，避免同图问题跨split。附录B：18,048标签中7678（42.54%）有空间偏好，平均3.66赢家；随机winner hit已达40.65%，held-out learned为55.34%。这与评测集21.5%的informative比例是不同样本集合。

## 主要结果与负证据

§4、表1：八benchmark共37,610样本；GQA、MMBench-en/cn、MME、POPE、MMStar、OCRBench、ChartQA，短答案greedy、最多16输出token。MME仅在macro汇总时除28。native macro78.85；均匀1/9压缩64.62；单区random67.98、training-only fixed68.48、learned69.61。selector相对random提高1.622分，paired bootstrap95% CI [1.085,2.161]。

**强缩放基线更好：** 实际19.82% token的matched-budget bicubic整图缩放为70.99，优于selector1.378分，CI [0.707,2.062]；约24.57%的2×缩放为72.43。selector在ChartQA57.84高于matched53.48，但OCR为58.40低于67.00。不能以局部救回案例概括总体优于整图缩放。

同20.99%预算的test-time oracle为82.73，比selector高13.124分；oracle使用测试结果选九路最大值，是**不可部署的上界**，其超过native不能说明学到的选择器已优于完整模型。表2使用独立matched rerun（full69.77，不是主表69.61）：tie-aware较任意one-hot好1.236分；去掉问题内容为69.80，full69.77，差-0.031，CI跨0。去掉问题和坐标还改变capacity，不能归因于单一输入。

## 失败信号与效率边界

§4.4、附录D：同3416样本、178正例（native正确且uniform错误），prefill-free图像平均keep logit AUC0.5239，compressed first-token entropy为0.7651；同fold OOF为0.5476/0.8072。它预测“是否压缩失败”，**不是九路区域选择质量**；后验不确定性已经付出LLM计算，不能免费用在单次前置selector。结果是该feature/probe的局部证据，不证明所有编码前网络都无法预测收益。

§5明确不主张E2E效率优势：比例只计进入LLM的token，方法运行完整ViT，像素缩放同时节省视觉编码；未给部署计时。单backbone、固定K1、其他八格的细节无法恢复也是作者局限。

## 对当前 Cx 的作用

关联 [[LLM-Wiki/concepts/methods/multimodal-token-pruning.md]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-liang-vip-router.md|VIP-Router]]、[[LLM-Wiki/research/visual-token-pruning/papers/2026-niu-evivit.md|EviViT]] 与 [[LLM-Wiki/research/visual-token-pruning/cx-global-local-importance-plan.md|Cx双重要性方案]]。

**本项目判断：** 这是单高清区+全局粗表示的直接近邻，可借鉴真实动作干预、并列标签和same-row probe，但它是post-ViT feature替换、固定九cell/21%预算，不等于小图、pre-ViT、至多单裁框的Cx。Cx的全局/条件局部NLL与标签收益仍需单独验证。优先保留整图缩放、随机/固定框、oracle gap、selector-only政策置换和匹配像素/预算对照；不能凭“有cross-attention”认定政策指导有效。

TODO：强缩放基线与pre-ViT实际计时、政策改变是否影响区域收益、局部清晰度与全局充分性分开、teacher收益稠密监督能否缩小oracle差距。暂不创建concept或改动正式motivation。
