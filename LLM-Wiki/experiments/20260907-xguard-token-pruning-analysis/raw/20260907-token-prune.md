---
id: 20260902-xguard-attr-generation
type: experiment
title: XGuard 41 类分类+归因生成与 Ghosted Layers 联合评测
status: active
created: 2026-09-02
updated: 2026-09-07
project_id: safety-classifier-compression
tags: [experiment, research, safety, model-pruning, layer-pruning, least-squares-recovery, ghosted-layers, xguard, multiclass, attribution, generation, perplexity, visual-token-pruning, fastv, divprune, vistok]
sources: [paper-yun-2026-ghosted-layers, paper-lu-2024-blockpruner, paper-chen-2024-fastv, paper-zhang-2025-sparsevlm, paper-alvar-2025-divprune]
---

# XGuard 41 类分类+归因生成与 Ghosted Layers 联合评测

> **状态：已完成并已更正（2026-09-06）。** 主实验完成了 7 条层剪枝/恢复条件。视觉压缩扩展的当前质量证据包括 L28_full/R15_ghosted 各三档**单次前向** FastV、各三档 DivPrune，以及两层变体各三档输入分辨率下采样；FastV、下采样质量和下采样 v3 timing 的 retain=1.0 门禁均通过。早期 FastV score-then-reencode 两段式产物保留为实现溯源 raw，但不再作为质量、时延、吞吐或跨方法比较的当前证据。下采样质量条件与 v3 timing 条件的 error rate 均不超过 0.001；v3 仅补充可比的 full-path 一-token计时，不改写质量、PPL、256-token 生成吞吐或 17 条件失败记录。

## 研究问题与假设

主问题：**在不更换训练数据、只更换训练目标（首 token → 完整 letter+归因）的前提下，Qwen3-VL-2B-Instruct 的 XGuard 41 类 LoRA 能否在首 token 质量基本不下降的同时，输出可读、高置信度的中文归因？**

子假设沿用来源实验的 H1–H4，并新增生成/PPL 维度：

1. **H1（首 token 质量保持）**：attr adapter 在 L28_full 下的 accuracy/macro recall 不低于来源实验 0.02（来源 accuracy=0.620、macro=0.4130）。
2. **H2（Ghost 恢复收益）**：同一删除计划下 Ghosted 变体的 macro recall 不低于恒等剪枝变体，且与来源实验的恢复量级相近。
3. **H3（归因拟合质量）**：L28_full 下 gold attribution 上的 teacher-forcing mean PPL 低于 8（经验阈值，对应 mean NLL ≈ 2.08），且 R45 Ghosted 相对 L28_full 的 PPL 上升不超过 ×1.5。
4. **H4（置信度一致性）**：on-generation self-PPL 与 teacher-forcing PPL 在 L28_full 下的差值不超过 2.0；剪枝越深差值越大。
5. **H5（吞吐与归因成本）**：在单卡 H20、batch=1、greedy、`use_cache=true` 下，L28_full 的完整生成吞吐（samples/s）不低于 1.0；首 token 时延与来源实验同口径可比。

H1–H5 均为本次单 seed、固定清单上的待验证假设，不预设 Ghosted 一定优于无剪枝或 attr 优于单 token。

## 固定数据、模型与校准集

| 项目 | 固定值 |
|---|---|
| 基座 | `Qwen/Qwen3-VL-2B-Instruct` |
| LoRA | r=8、alpha=16、dropout=0.05，层 0–27 的 7 个投影；`task_type=CAUSAL_LM` |
| 训练清单 | `derived/xguard_multiclass_train_10000_seed20260901.json`（10,000 条），SHA256=`2a36ee691c0d289740761c477a9782dc848e6b472c7a0b292e2427ebdbe223c7`；训练前在脚本内过滤 2 条 `output="A\n"` 空归因样本，实际参与优化 9,998 条 |
| 评测清单 | `derived/xguard_multiclass_eval_1000_seed20260901_with_attr.json`（1,000 条 + `pred_reason` 拼接的 `output` 字段），SHA256=`b6dfc07fcdb8d979ae55d27395c1005b353dad3585d0666fdff21bf72a9a949c` |
| 校准集 | `derived/xguard_multiclass_layer_calib_256_seed20260902.json`，256 条；复用来源实验 |
| 注意力 | 训练 `sdpa`；评测/打分/拟合/合并 `eager` |
| 数值 | 模型 bf16；Gram 累积 fp32；最小二乘求解 fp64 CPU；ridge λ=`1e-6` |
| 训练超参 | `batch_size=1`、`max_len=32768`、`lr=2e-4`、`gradient_checkpointing=True`、1 epoch |
| 损失 | 对完整 `<letter>\n<attribution><eos>` 等权交叉熵（**不再**对归因 token 乘以 0.25） |
| DeepStack | 层 0/1/2 排除出删除候选 |

XGuard 原生 `input`、唯一 `<image>` 占位符、大小写敏感单 token 类别码和"首行类别码、第二行单段归因"输出协议保持不变。评测仍只以首 token 解析类别，但额外记录完整生成、归因文本和两段 PPL。

## 变量、基线与条件

层分数定义与来源实验完全一致：每层 MHA 与 MLP 两块 `mean(|gradient × weight|)` 的均值，先对每个标签内平均，再对 41 个标签等权平均，最后在 28 层间 z-score。排除层 0–2 后按分数由低到高形成嵌套计划：R15 删除 4 层、R30 删除 8 层、R45 删除 12 层。**层计划从 attr 合并后的 checkpoint 重新计算**，不复用来源实验的 `xguard_layer_plans_gradient_weight.json`，以反映 attr adapter 自身的梯度结构。

| 条件 | 删除层数 | 替代方式 |
|---|---:|---|
| `xguard_attr_lgw_L28_full` | 0 | 无剪枝统一协议基线 |
| `xguard_attr_lgw_R15_pruned/ghosted` | 4 | 零参数直通 / Ghost 线性层 |
| `xguard_attr_lgw_R30_pruned/ghosted` | 8 | 零参数直通 / Ghost 线性层 |
| `xguard_attr_lgw_R45_pruned/ghosted` | 12 | 零参数直通 / Ghost 线性层 |

Ghost 拟合 `Y ≈ XW + b`，安装到 `nn.Linear` 时使用 `weight=Wᵀ`。每个条件前执行安装后首样本门禁。

## 指标与端到端性能协议

### 质量指标

- **首 token**：accuracy、24 个有支持类的 macro recall、`support >= 20` macro recall、41 类 precision/recall/F1/support、invalid rate、error rate 及 41 类混淆矩阵。
- **Teacher-forcing attribution PPL（`gold_attr_ppl`）**：将 ground-truth `<gold_letter>\n<gold_attribution>` 拼接在 prompt 后做 teacher-forcing forward，**只在归因 token 段**（不含 letter 和紧跟的 newline）聚合 mean NLL，再 `exp(min(nll, 20))` 得到 PPL。报告 per-sample mean、token-weighted mean、median、P50、P95。参考归因来自 full eval JSONL 的 `pred_reason`。
- **On-generation self-PPL（`self_attr_ppl`）**：在生成时通过 `output_scores=True` 拿到每步 logits，取已生成 token 的 log-prob，在归因段聚合 mean NLL 后 `exp(min(nll, 20))`。不消耗额外前向。

### 性能协议

固定 NVIDIA H20-3e、batch=1、greedy、`max_new_tokens=256`。层剪枝基线的一-token参考时延使用 `use_cache=false`；生成使用 `use_cache=true`。每条件先以固定首样本 warm-up 一次，再逐条执行全部 1,000 条：

- `image_io_ms`：本地缓存图片读取 + 解码（计时前所有 URL 已 prefetch）；
- `processor_ms`：已解码 PIL 图像到 CUDA 输入张量；v3 下采样额外包含缩图和其后的 CUDA 输入构造；
- `first_token_ms`：单次前向 FastV 为视觉构建（不含独立 LLM 打分）+ 在 layer 1 裁剪后的 prefill + 首 token argmax；其 prefill 同时建立后续 greedy decode 的 KV cache。层剪枝基线的同名字段是 `use_cache=false` 的独立 raw-input 前向，DivPrune 和 resize 的历史同名字段仅从已构建状态开始；
- `full_path_ttft_ms`（v2/v3）：从 ready processor inputs 开始。v2 完整模型直接测一 token，DivPrune 计入视觉编码、选择/压缩和一-token生成；v3 下采样在 ready 的缩图输入上执行 raw 一-token调用，计入缩图后的视觉编码和一-token生成，但不计入 `processor_ms` 中的缩图/传输；
- `total_generate_ms`：从已选择的视觉状态开始的 `max_new_tokens=256`、`use_cache=true` 生成调用，包含首 token；
- `pipeline_e2e_ms`：历史名称，实际为 processor + 模型生成，排除 image I/O、诊断性一-token调用和 teacher-forcing PPL；
- `gold_attr_ppl_ms`：teacher-forcing PPL forward 的墙钟；单次前向 FastV 的 gold PPL 使用相同的 layer-1 keep set 通过裁剪前向计算；
- `wall_ms_including_image_io`：包含本地缓存图片读取的运行墙钟。

`total_generate_ms` 的 RPS 是成功样本上的 generate-call 吞吐，不是完整请求或 token-normalized 吞吐。单次前向 FastV 与 DivPrune 的全口径首 token 对比由 `analyze_xguard_attr_singlepass.py` 从各自 canonical raw/summary 汇总；v2（完整模型/DivPrune）与 v3（resize）共享 ready-input full-path 边界，但为独立版本化运行，不能据此给出跨运行置信区间。v3 只重测一-token计时，不改写质量、PPL 或 256-token 生成结果。

## 门禁、成功标准、预算与停止条件

- **G-merge**：adapter 合并前后固定图文 probe 的末位置 logits 最大绝对差为 0，首 token 类别一致。
- **G-calib**：复用来源实验的 256 条校准集，覆盖 41 类。
- **G-token**：41 个类别码均为唯一可逆单 token。
- **G-fit**：12 个候选层均产生有限矩阵和有限相对拟合误差；安装前后冒烟预测均为有效类别。
- **G-eval**：每条件保留固定 1,000 个 sample ID，无缺失、额外或重复。
- **成功标准**：H1 accuracy 相对来源实验不低于 −0.02；H2 Ghost ≥ 恒等；H3 L28_full gold PPL < 8、R45 Ghost / L28_full < 1.5；H4 self-PPL − gold PPL < 2.0（L28_full）；H5 L28_full 完整生成吞吐 > 1.0 samples/s。
- **预算**：一次 LoRA 训练、一次合并、一次 256 条打分、一次 256 条/12 层拟合、7 条件 × 1,000 样本评测。
- **停止**：G-merge/G-calib/G-token 失败即停止；校准有效样本少于 240、任一拟合值非有限或任一评测条件 error rate 超过 1% 时停止后续条件。

## 预定产物

代码位于 `/home/ljm534318/qwen3vl_prune_exp/`，使用独立命名：

- `lora_adapter_xguard_multiclass_attr/`；
- `merged_model_xguard_multiclass_attr/` 与 `derived/xguard_attr_merge_model_gates.json`；
- `derived/xguard_multiclass_eval_1000_seed20260901_with_attr.json`（评测清单增强版）；
- `derived/xguard_attr_layer_scores_gradient_weight.json`、`derived/xguard_attr_layer_plans_gradient_weight.json`；
- `derived/xguard_attr_ghost_bundle/`（`ghost_matrices.pt` + `fit_stats.json`）；
- 7 份 `raw/raw_xguard_attr_lgw_*_1k.json` 与 7 份 `derived/xguard_attr_lgw_*_1k_summary.json`；
- `evaluate_xguard_attr_vistok_singlepass.py` 与 L28_full/R15_ghosted 各三档的六份 canonical FastV 单次前向结果 `raw/raw_xguard_attr_lgw_{L28_full,R15_ghosted}_fastv_p{25,50,75}_1k.json` / 对应 summary；
- `derived/xguard_attr_vistok_1pass_gate.json`（L28_full/R15_ghosted 的 prefill 20/20 与 decode 4/4 等价门禁）；
- 6 份 DivPrune 结果 `raw/raw_xguard_attr_lgw_{L28_full,R15_ghosted}_divprune_p{25,50,75}_1k.json` / 对应 summary；早期 `*_fastv_*_reencode.json` 及其 summary/log 仅作已废弃两段式实现的溯源保存；
- `evaluate_xguard_attr_vistok_timing_v2.py`、`derived/xguard_attr_vistok_timing_v2_gate_10.json` 与 8 份版本化 raw/summary：`raw/raw_xguard_attr_lgw_{L28_full,L28_full_divprune_p25,L28_full_divprune_p50,L28_full_divprune_p75,R15_ghosted,R15_ghosted_divprune_p25,R15_ghosted_divprune_p50,R15_ghosted_divprune_p75}_timing_v2_1000.json` / 对应 summary；它们仅更正可比 full-path TTFT，不改写历史质量、PPL 或 256-token 生成结果；
- `evaluate_xguard_attr_resize.py` 与 6 份不可变下采样质量/生成结果 `raw/raw_xguard_attr_lgw_*_resize_*_1k.json` / `derived/xguard_attr_lgw_*_resize_*_1k_summary.json`；
- `evaluate_xguard_attr_resize_timing_v3.py`、`derived/xguard_attr_resize_timing_v3_gate_10.json` 与 6 份版本化 raw/summary：`raw/raw_xguard_attr_lgw_{L28_full,R15_ghosted}_resize_p{25,50,75}_timing_v3_1000.json` / 对应 `derived/*_summary.json`；运行中的原子 `raw/*.partial.json` checkpoint 会在完成后删除；
- `analyze_xguard_attr_per_label_recall.py` 与 `derived/xguard_attr_per_label_recall_support_ge10_1k.json`：对 25 份当前质量 raw/summary 重算真实标签逐类召回、校验固定 manifest/既有 summary，并仅保留 support ≥ 10 的标签；
- `derived/xguard_attr_resize_gate.json`（下采样 retain=100% 质量等价门禁）与 `derived/xguard_attr_failure_records_1k.json`（历史 17 条件 × 1,000 条生成结果的轻量级失败样本对比记录；不包含 timing-only v3）；
- 完整 stdout/stderr 日志保存在 `logs/`，不覆盖来源实验文件。

## 执行记录与结果

### 环境、命令与门禁

执行环境与来源实验一致：Python 3.10.19、torch 2.10.0+cu128、CUDA 12.8、transformers 4.57.6、peft 0.19.1、accelerate 1.14.0、torchvision 0.25.0+cu128，硬件为单张 NVIDIA H20-3e（139.8 GiB）。

```bash
# 训练（sdpa, gradient checkpointing, bs=1, max_len=32768, 1 epoch）
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/lora_finetune_xguard_multiclass_attr.py \
  2>&1 | tee /home/ljm534318/qwen3vl_prune_exp/logs/xguard_multiclass_attr_ft_10k_bs1_max32768_sdpa_gc_seed20260901.log

# 评测清单增强（把 full eval JSONL 的 pred_reason 拼成 <letter>\n<reason>）
/home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/build_xguard_multiclass_eval_with_attr.py

# 合并 + G-merge
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/merge_model_xguard_multiclass_attr.py

# 层打分
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/layer_scores_xguard_multiclass_attr.py

# Ghost 拟合
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/ghosted_prune_xguard_multiclass_attr.py --prefetch
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/ghosted_prune_xguard_multiclass_attr.py --fit-only

# 7 条件评测
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/ghosted_prune_xguard_multiclass_attr.py \
  --conditions L28_full R15_pruned R15_ghosted R30_pruned R30_ghosted R45_pruned R45_ghosted

# resize v3：retain=1 identity gate，再按 display p25/p50/p75 跑六条 timing-only 条件
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/evaluate_xguard_attr_resize_timing_v3.py \
  --gate --gate-samples 10
HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1 PYTORCH_ALLOC_CONF=expandable_segments:True \
  /home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/evaluate_xguard_attr_resize_timing_v3.py \
  --conditions L28_full_resize_p75 L28_full_resize_p50 L28_full_resize_p25 \
    R15_ghosted_resize_p75 R15_ghosted_resize_p50 R15_ghosted_resize_p25

# CPU-only：从 25 份当前质量 raw/summary 重算真实标签逐类召回
/home/ljm534318/qwen3vl_prune_exp/.venv-xguard/bin/python \
  /home/ljm534318/qwen3vl_prune_exp/analyze_xguard_attr_per_label_recall.py
```

### 训练曲线

loss 为完整输出序列的等权交叉熵；`class_loss` 仅覆盖 letter 前缀 token；`reason_loss` 覆盖归因段。step `125/225/525/1175/1475/3375/7175/9998` 的 `(loss, class_loss, reason_loss)` 依次为 `(2.3205, 1.2102, 2.3342)`、`(2.1815, 1.0558, 2.1954)`、`(2.0028, 0.8392, 2.0172)`、`(1.8596, 0.6529, 1.8745)`、`(1.8040, 0.6033, 1.8189)`、`(1.6514, 0.5064, 1.6656)`、`(1.5151, 0.4301, 1.5285)`、`(1.4655, 0.4061, 1.4787)`。

训练总耗时 `5206.4 s`（约 86.8 min），最终 mean loss `1.4655`（class `0.4061`，reason `1.4787`）。过滤 2 条空归因样本后实际参与优化 9,998 条。class_loss 下降更快说明 letter 预测先于归因质量收敛；这与来源实验 `class_loss + 0.25 × reason_loss` 加权下"分类优先"的行为一致，但本实验在等权损失下仍观察到 class_loss 更早进入平台。

### 门禁结果

- **G-merge**：通过。合并前后 probe logits `max_abs_diff=0.0`，首 token 类别均为 `I`（token ID 40）。
- **G-calib**：通过。256 条校准样本中 255 条有效（1 条失败），覆盖全部 41 类。
- **G-token**：通过。41 个类别码均为唯一可逆单 token。
- **G-fit**：通过。12 个候选层全部产生有限矩阵；相对拟合误差 L3–L7 约 0.011–0.016（早期层），L19–L27 约 0.083–0.111（尾部层，预期更高因 bias norm 大）。冒烟门禁 `status=ok`，baseline→`I`，ghosted→`A`（均有效类别）。

### 层计划与 Ghosted Layers

Attr adapter 的梯度结构与来源实验不同：R15 删除 `[24, 25, 26, 27]`（LM 参数 11.70%），R30 删除 `[3, 4, 22, 23, 24, 25, 26, 27]`（23.40%），R45 删除 `[3, 4, 5, 7, 19, 20, 22, 23, 24, 25, 26, 27]`（35.11%）。来源实验的对应计划分别为 `[3, 4, 26, 27]`、`[3, 4, 5, 23, 24, 25, 26, 27]` 和 `[3, 4, 5, 6, 7, 16, 19, 23, 24, 25, 26, 27]`，因此两实验的同名剪枝率不代表相同结构干预。尤其 attr R15 仅删除尾部层，不能与来源的混合早期/尾部 R15 直接等同。

7 条件全部完成（2026-09-03 09:53–18:02，总耗时约 8.2 h）。表中的 Ghost 恢复为同一层计划下 ghosted 相对直通 pruned 的 `Δaccuracy / Δmacro recall`；`macro≥20` 仅对评测集中支持数至少 20 的类别求平均；`invalid / error` 分别为无效类别码和运行错误率。

| 层计划 | 条件 | accuracy | macro recall | macro≥20 | Ghost 恢复 | invalid / error | raw-input no-cache TTFT P50 (ms) |
|---|---|---:|---:|---:|---:|---:|---:|
| 全层 | L28_full | **0.6160** | **0.4326** | **0.5187** | — | 0.001 / 0.001 | 131.5 |
| R15 | pruned | 0.4850 | 0.2784 | 0.3674 | — | 0.108 / 0.001 | 124.3 |
| R15 | ghosted | 0.6060 | 0.3900 | 0.4808 | +0.1210 / +0.1116 | 0.001 / 0.001 | 124.5 |
| R30 | pruned | 0.1330 | 0.0529 | 0.0906 | — | 0.454 / 0.001 | 117.2 |
| R30 | ghosted | 0.4600 | 0.2381 | 0.3401 | +0.3270 / +0.1852 | 0.001 / 0.001 | 117.8 |
| R45 | pruned | 0.0000 | 0.0000 | 0.0000 | — | 1.000 / 0.001 | 109.5 |
| R45 | ghosted | 0.3180 | 0.1254 | 0.2149 | +0.3180 / +0.1254 | 0.001 / 0.001 | 110.8 |

Ghost 在三种删除比例均恢复了首 token 质量，尤其将 R45 从全无效类别码恢复为 0.3180 accuracy；但恢复并未等价于归因生成恢复。L28_full、R15/R30/R45 ghosted 的 gold PPL 均值依次为 `5.28/16.15/33.20/142.14`，对应 self-PPL 为 `1.82/2.15/1.92/2.34`；gold PPL 的 P50/P95 依次为 `4.95/9.08`、`14.90/28.62`、`31.07/58.54`、`128.83/270.57`。四个条件的平均归因字符数为 `213/274/321/362`，表明更深剪枝下生成更长但与 teacher 参考更不一致；self-PPL 保持低值不能替代 gold PPL。

#### 按真实标签的逐类召回（support ≥ 10）

`derived/xguard_attr_per_label_recall_support_ge10_1k.json` 由 25 份当前质量 raw/summary 对重新汇总；本表使用其中 7 个层剪枝条件。每格为 `gold=该标签且 pred=该标签 / gold=该标签`，`pred="invalid"` 的无效类别码和带 `error` 的样本均保留在分母并计为漏检。固定清单中仅 16 个标签的真实 support 至少为 10；其余 8 个非零 support 标签（1–9 条）不报告。数值为召回率，保留三位小数。

| 代码 | 真实标签 | n | L28_full | R15_pruned | R15_ghosted | R30_pruned | R30_ghosted | R45_pruned | R45_ghosted |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| A | 未命中 | 138 | 0.884 | 0.457 | 0.884 | 0.536 | 0.935 | 0.000 | 0.993 |
| B | 现任一号负面 | 42 | 0.762 | 0.667 | 0.643 | 0.429 | 0.571 | 0.000 | 0.286 |
| D | 六四相关 | 150 | 0.480 | 0.533 | 0.553 | 0.000 | 0.447 | 0.000 | 0.420 |
| E | 国家主权分裂 | 55 | 0.382 | 0.382 | 0.364 | 0.000 | 0.000 | 0.000 | 0.000 |
| F | 反党反政府 | 38 | 0.605 | 0.000 | 0.553 | 0.000 | 0.395 | 0.000 | 0.026 |
| H | 成人色情 | 135 | 0.896 | 0.822 | 0.874 | 0.304 | 0.926 | 0.000 | 0.607 |
| I | 未成年色情 | 89 | 0.888 | 0.921 | 0.921 | 0.000 | 0.213 | 0.000 | 0.000 |
| L | 色情服务 | 21 | 0.048 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| M | 成人性暗示 | 34 | 0.706 | 0.000 | 0.500 | 0.000 | 0.706 | 0.000 | 0.676 |
| N | 虐恋低俗 | 43 | 0.047 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| O | 成人低俗 | 13 | 0.231 | 0.538 | 0.462 | 0.000 | 0.231 | 0.000 | 0.000 |
| P | 未成年低俗 | 52 | 0.019 | 0.000 | 0.038 | 0.000 | 0.000 | 0.000 | 0.000 |
| T | 恐怖主义 | 88 | 0.898 | 0.864 | 0.875 | 0.000 | 0.568 | 0.000 | 0.000 |
| f | 未成年侵害 | 22 | 0.227 | 0.182 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| g | 未成年不良行为 | 17 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| h | 血腥暴力 | 38 | 0.421 | 0.316 | 0.526 | 0.000 | 0.000 | 0.000 | 0.000 |

逐类观察只限此固定 1,000 条评测集。支持数至少 20 的类别中，R15 Ghost 相对 R15 pruned 的最大召回恢复为 `F`（反党反政府，38 条，`0.000→0.553`）、`M`（成人性暗示，34 条，`0.000→0.500`）和 `A`（未命中，138 条，`0.457→0.884`）。这些是逐类恢复的描述性结果，不构成跨 seed 或总体分布推断。

细粒度时延显示，L28_full 与 R15/R30/R45 ghosted 的 image I/O mean 分别为 `18.7/14.8/17.0/16.0 ms`，processor mean 为 `19.0/20.0/18.3/19.2 ms`，完整生成 mean 为 `3584.7/4274.1/4641.7/4050.6 ms`，processor+model pipeline mean 为 `3603.3/4293.7/4659.6/4069.3 ms`（不含 image I/O 与 teacher-forcing PPL）。表中的 no-cache TTFT 与来源实验同口径：L28_full 为 131.5 ms，来源为 131.3 ms；而 256-token 完整生成吞吐为 0.279 samples/s，主要受解码长度影响，不能与单 token 分类吞吐直接比较。

### 视觉压缩：L28_full 与 R15_ghosted（2026-09-06 更正）

早期 FastV 使用 `score-then-reencode` 两段式适配：先运行 layer-1 打分前向，再对压缩序列重新 prefill，记录的 `first_token_ms` 未计入前一段打分。因此对应 `*_reencode.json`、summary 和日志仅保留为实现溯源，绝不作为当前质量、时延、吞吐或 FastV—DivPrune 比较证据。

当前 FastV 实现为 `evaluate_xguard_attr_vistok_singlepass.py` 中的 `vis_tok_prune.single_pass_fastv_prefill()`：层 0–1 保持完整序列，layer 1 的注意力打分确定 keep set；同一次 prefill 随后压缩 hidden states、KV cache、M-RoPE、注意力 mask 与尚未注入的 DeepStack 特征，层 2+ 与 greedy decode 均使用该压缩序列/cache。teacher-forcing gold PPL 也通过同一 keep set 的裁剪前向计算。`derived/xguard_attr_vistok_1pass_gate.json` 已验证 L28_full/R15_ghosted 的 retain=1.0 prefill 20/20 一致和 decode 4/4 一致。补齐 R15 三条件的可续跑评测于 2026-09-06 12:28–15:38 完成，墙钟约 3.17 h；L28 三条件此前已完成，故不将两个独立运行窗口合并为单一总时长。为纠正 DivPrune 的历史计时范围，`evaluate_xguard_attr_vistok_timing_v2.py` 另以固定 1,000 条清单测量：从相同的 ready processor inputs 开始，完整模型直接测一 token，DivPrune 则计入视觉编码、选择/压缩和一-token生成。其 identity gate 为 20/20 通过。随后 `evaluate_xguard_attr_resize_timing_v3.py` 用相同 ready-input 边界重测六条 resize 条件：缩图和输入传输先完成，raw 一-token调用计入缩图后的视觉编码和生成；其 retain=1.0 identity gate 同为 20/20 通过。`pXX` 为展示剪枝率，`retain` 为实际保留率。

| 层条件 | 视觉压缩方法 | 剪枝率 | retain | accuracy | macro recall | macro≥20 | invalid / error | gold / self PPL | 首 token P50（口径） | 256-token generate-call rps |
|---|---|---:|---:|---:|---:|---:|---:|---:|---|---:|
| L28_full | 无视觉压缩 | 0% | 1.000 | 0.6160 | 0.4326 | 0.5187 | 0.001 / 0.001 | 5.28 / 1.82 | 132.0（v2 full-path） | 0.279 |
| L28_full | FastV | p25 | 0.749 | 0.6150 | 0.4288 | 0.5123 | 0.001 / 0.001 | 5.45 / 1.83 | 121.1（单次前向） | 0.319 |
| L28_full | FastV | p50 | 0.500 | 0.6030 | 0.4277 | 0.5004 | 0.001 / 0.001 | 5.84 / 1.83 | 115.1（单次前向） | 0.327 |
| L28_full | FastV | p75 | 0.249 | 0.5550 | 0.3876 | 0.4417 | 0.001 / 0.001 | 6.76 / 1.84 | 107.7（单次前向） | 0.345 |
| L28_full | DivPrune | p25 | 0.749 | 0.6120 | 0.4286 | 0.5065 | 0.001 / 0.001 | 5.31 / 1.82 | 133.4（v2 full-path） | 0.278 |
| L28_full | DivPrune | p50 | 0.500 | 0.6030 | 0.4176 | 0.5010 | 0.001 / 0.001 | 5.39 / 1.83 | 123.9（v2 full-path） | 0.280 |
| L28_full | DivPrune | p75 | 0.249 | 0.5770 | 0.4061 | 0.4788 | 0.001 / 0.001 | 5.71 / 1.86 | 111.3（v2 full-path） | 0.286 |
| L28_full | 输入分辨率下采样 | p25 | 0.752 | 0.6020 | 0.3981 | 0.5062 | 0.001 / 0.001 | 5.33 / 1.82 | 101.1（v3 full-path） | 0.284 |
| L28_full | 输入分辨率下采样 | p50 | 0.504 | 0.5890 | 0.3815 | 0.5007 | 0.001 / 0.001 | 5.44 / 1.85 | 64.6（v3 full-path） | 0.286 |
| L28_full | 输入分辨率下采样 | p75 | 0.250 | 0.5660 | 0.3777 | 0.4762 | 0.000 / 0.000 | 5.74 / 1.88 | 48.2（v3 full-path） | 0.285 |
| R15_ghosted | 无视觉压缩 | 0% | 1.000 | 0.6060 | 0.3900 | 0.4808 | 0.001 / 0.001 | 16.15 / 2.15 | 124.6（v2 full-path） | 0.234 |
| R15_ghosted | FastV | p25 | 0.749 | 0.6070 | 0.3944 | 0.4805 | 0.001 / 0.001 | 16.69 / 2.16 | 115.3（单次前向） | 0.270 |
| R15_ghosted | FastV | p50 | 0.500 | 0.6000 | 0.4029 | 0.4673 | 0.001 / 0.001 | 17.91 / 2.15 | 110.3（单次前向） | 0.274 |
| R15_ghosted | FastV | p75 | 0.249 | 0.5460 | 0.3541 | 0.4173 | 0.001 / 0.001 | 20.69 / 2.13 | 103.8（单次前向） | 0.294 |
| R15_ghosted | DivPrune | p25 | 0.749 | 0.5990 | 0.3962 | 0.4736 | 0.001 / 0.001 | 16.25 / 2.16 | 129.2（v2 full-path） | 0.227 |
| R15_ghosted | DivPrune | p50 | 0.500 | 0.5800 | 0.3857 | 0.4556 | 0.001 / 0.001 | 16.56 / 2.14 | 119.4（v2 full-path） | 0.230 |
| R15_ghosted | DivPrune | p75 | 0.249 | 0.5570 | 0.3414 | 0.4411 | 0.001 / 0.001 | 17.64 / 2.14 | 107.9（v2 full-path） | 0.230 |
| R15_ghosted | 输入分辨率下采样 | p25 | 0.752 | 0.5850 | 0.3548 | 0.4587 | 0.001 / 0.001 | 16.34 / 2.13 | 94.8（v3 full-path） | 0.232 |
| R15_ghosted | 输入分辨率下采样 | p50 | 0.504 | 0.5720 | 0.3527 | 0.4551 | 0.001 / 0.001 | 16.73 / 2.15 | 59.5（v3 full-path） | 0.232 |
| R15_ghosted | 输入分辨率下采样 | p75 | 0.250 | 0.5410 | 0.3522 | 0.4319 | 0.000 / 0.000 | 17.71 / 2.14 | 44.9（v3 full-path） | 0.236 |

#### 视觉压缩按真实标签的逐类召回（support ≥ 10）

下表复用上节的真实标签、support、分母和三位小数口径，数据来自 `derived/xguard_attr_per_label_recall_support_ge10_1k.json` 的当前质量条件。`baseline` 分别复用 L28_full 与 R15_ghosted 层剪枝 raw；仅包含 canonical 单次前向 FastV、DivPrune 和历史 quality/generation resize raw，不包含 v2/v3 timing-only 或已废弃 `*_reencode` 数据。`resize p25/p50/p75` 仍按展示剪枝率映射到不可变 source condition `resize_p75/p50/p25`。

**L28_full**

| 代码 | n | baseline | FastV p25 | FastV p50 | FastV p75 | DivPrune p25 | DivPrune p50 | DivPrune p75 | resize p25 | resize p50 | resize p75 |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A | 138 | 0.884 | 0.906 | 0.913 | 0.942 | 0.877 | 0.891 | 0.913 | 0.877 | 0.884 | 0.899 |
| B | 42 | 0.762 | 0.690 | 0.690 | 0.429 | 0.738 | 0.690 | 0.619 | 0.619 | 0.738 | 0.690 |
| D | 150 | 0.480 | 0.487 | 0.467 | 0.347 | 0.500 | 0.473 | 0.413 | 0.467 | 0.427 | 0.360 |
| E | 55 | 0.382 | 0.400 | 0.345 | 0.291 | 0.400 | 0.364 | 0.291 | 0.273 | 0.291 | 0.327 |
| F | 38 | 0.605 | 0.553 | 0.526 | 0.579 | 0.553 | 0.553 | 0.526 | 0.605 | 0.553 | 0.526 |
| H | 135 | 0.896 | 0.896 | 0.896 | 0.904 | 0.911 | 0.867 | 0.837 | 0.889 | 0.889 | 0.874 |
| I | 89 | 0.888 | 0.888 | 0.831 | 0.719 | 0.865 | 0.876 | 0.831 | 0.899 | 0.876 | 0.820 |
| L | 21 | 0.048 | 0.048 | 0.048 | 0.048 | 0.048 | 0.000 | 0.048 | 0.095 | 0.048 | 0.000 |
| M | 34 | 0.706 | 0.765 | 0.706 | 0.647 | 0.706 | 0.765 | 0.735 | 0.765 | 0.735 | 0.676 |
| N | 43 | 0.047 | 0.047 | 0.070 | 0.000 | 0.000 | 0.023 | 0.023 | 0.023 | 0.000 | 0.000 |
| O | 13 | 0.231 | 0.231 | 0.231 | 0.231 | 0.308 | 0.231 | 0.154 | 0.077 | 0.231 | 0.231 |
| P | 52 | 0.019 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.019 | 0.038 |
| T | 88 | 0.898 | 0.898 | 0.898 | 0.886 | 0.898 | 0.909 | 0.864 | 0.920 | 0.830 | 0.773 |
| f | 22 | 0.227 | 0.227 | 0.273 | 0.182 | 0.227 | 0.182 | 0.182 | 0.182 | 0.273 | 0.182 |
| g | 17 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| h | 38 | 0.421 | 0.368 | 0.342 | 0.211 | 0.368 | 0.421 | 0.421 | 0.474 | 0.447 | 0.500 |

**R15_ghosted**

| 代码 | n | baseline | FastV p25 | FastV p50 | FastV p75 | DivPrune p25 | DivPrune p50 | DivPrune p75 | resize p25 | resize p50 | resize p75 |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| A | 138 | 0.884 | 0.884 | 0.891 | 0.920 | 0.862 | 0.862 | 0.891 | 0.870 | 0.862 | 0.870 |
| B | 42 | 0.643 | 0.643 | 0.643 | 0.357 | 0.643 | 0.619 | 0.548 | 0.571 | 0.690 | 0.619 |
| D | 150 | 0.553 | 0.560 | 0.553 | 0.393 | 0.547 | 0.533 | 0.480 | 0.527 | 0.473 | 0.400 |
| E | 55 | 0.364 | 0.400 | 0.345 | 0.182 | 0.364 | 0.255 | 0.291 | 0.255 | 0.273 | 0.218 |
| F | 38 | 0.553 | 0.553 | 0.526 | 0.579 | 0.526 | 0.500 | 0.526 | 0.553 | 0.526 | 0.500 |
| H | 135 | 0.874 | 0.867 | 0.889 | 0.896 | 0.874 | 0.837 | 0.778 | 0.874 | 0.867 | 0.830 |
| I | 89 | 0.921 | 0.910 | 0.854 | 0.753 | 0.888 | 0.876 | 0.820 | 0.899 | 0.843 | 0.831 |
| L | 21 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| M | 34 | 0.500 | 0.471 | 0.441 | 0.412 | 0.441 | 0.471 | 0.353 | 0.412 | 0.382 | 0.353 |
| N | 43 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| O | 13 | 0.462 | 0.462 | 0.462 | 0.462 | 0.462 | 0.462 | 0.462 | 0.538 | 0.538 | 0.462 |
| P | 52 | 0.038 | 0.077 | 0.038 | 0.038 | 0.058 | 0.058 | 0.077 | 0.058 | 0.058 | 0.115 |
| T | 88 | 0.875 | 0.864 | 0.886 | 0.864 | 0.875 | 0.841 | 0.807 | 0.852 | 0.818 | 0.705 |
| f | 22 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| g | 17 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 | 0.000 |
| h | 38 | 0.526 | 0.500 | 0.474 | 0.447 | 0.553 | 0.526 | 0.605 | 0.553 | 0.579 | 0.605 |

六条 FastV 行均来自 canonical 单次前向 raw/summary。`analyze_xguard_attr_singlepass.py` 以全口径 `first_token_ms` 对比 FastV 与 DivPrune：L28 的 FastV `121.1/115.1/107.7 ms` 低于 DivPrune `134.0/123.9/111.9 ms`，R15 的 FastV `115.3/110.3/103.8 ms` 低于 DivPrune `128.7/119.1/108.4 ms`（均为 p25/p50/p75）。这与表中版本化 DivPrune v2 full-path 值是不同运行的互补计时证据，不能据此给出跨运行的置信区间；方向上两组数据均支持单次前向 FastV 低于同档 DivPrune。历史 DivPrune `45.6/39.4/31.8 ms`（L28）和 `40.2/34.8/28.5 ms`（R15）同样仅是已压缩状态的一-token诊断，不能与 raw-input baseline TTFT 比较。

相对 `analyze_xguard_attr_singlepass.py` 的基线，FastV p25 的首 token P50 由 L28 的 `131.5→121.1 ms`（−7.9%）和 R15 的 `124.5→115.3 ms`（−7.4%）。质量上，L28 FastV p25 几乎保持基线（accuracy `0.6150`、macro `0.4288`）；R15 FastV p25/p50 的 accuracy 为 `0.6070/0.6000`，高于同档 DivPrune `0.5990/0.5800`，但 gold PPL 较高（`16.69/17.91` vs `16.25/16.56`）。p75 时 FastV accuracy 低于 DivPrune（`0.5460` vs `0.5570`），但 macro recall 略高（`0.3541` vs `0.3414`）；其 gold PPL 仍更高（`20.69` vs `17.64`）。

256-token generate-call RPS 仍只衡量已选择视觉状态后的生成：R15 Ghost 基线/FastV p25/p50/p75 为 `0.234/0.270/0.274/0.294` samples/s，DivPrune 为 `0.234/0.227/0.230/0.230`。FastV 的生成调用吞吐随剪枝率升高而改善，但这些单请求顺序测量仍受自回归 decode 和生成长度影响，既不是完整请求 RPS，也不是 token-normalized 吞吐。

支持数至少 20 的逐类召回中，R15 DivPrune p75 相对 R15 Ghost 的最大下降为 `M`（34 条，`0.500→0.353`）、`I`（89 条，`0.921→0.820`）和 `H`（135 条，`0.874→0.778`）；`h`（38 条）从 `0.526→0.605`。这些固定清单上的翻转不支持具体视觉语义机制的断言。所有可报告 FastV、DivPrune 和下采样数值均在上表；对应 canonical FastV、DivPrune、下采样质量、v2 timing 与 v3 timing summaries 的路径已在预定产物中登记。

### 输入分辨率下采样与失败记录

下采样在视觉编码器前按目标面积缩图，并向 `patch_size × merge_size=32` 对齐后以 `do_resize=False` 调用 processor，因此不会被重新上采样；原始质量评测的 L28_full/R15_ghosted retain=1.0 门禁与 v3 timing 的 retain=1.0 identity gate 均通过（各 20/20）。为与 FastV/DivPrune 统一，表中的 `resize pXX` 一律表示**剪枝率**：展示的 p25/p50/p75 分别映射到不可变质量 raw/summary 后缀 `resize_p75/p50/p25`，对应实际 visual-token retain P50 `0.752748/0.504386/0.250000`。v3 condition ID 沿用该 suffix 语义，同时以 `display_prune_label` 显式保存展示标签；历史 `resize_pXX` 文件名保持目标**保留率**的原义，不得改名或覆盖。

六个条件的完整质量、PPL 和 256-token 生成指标保留于不可变的 `derived/xguard_attr_lgw_*_resize_*_1k_summary.json`，并已列入上方视觉压缩表。展示 p25/p50（历史 artifact p75/p50）各保留同一条 eager OOM（error rate 0.001），展示 p75（历史 artifact p25）无错误。v3 同样在该超大样本上保留 p25/p50 的单条 one-token OOM（各 error rate 0.001），p75 无错误；时延聚合只使用成功样本，未插补。

表中下采样的首 token P50 已替换为 v3 `full_path_ttft_ms`：从 ready 的缩图 processor inputs 开始，raw 一-token调用计入缩图后的视觉编码和生成。其 p25/p50/p75 P50 分别为 L28 `101.1/64.6/48.2 ms`、R15 Ghost `94.8/59.5/44.9 ms`，可与同表的 v2 DivPrune ready-input full-path 值比较，但 v2/v3 是独立运行，不能据此估计跨运行方差。历史 `46.5/38.7/31.9 ms`（L28）与 `40.9/34.3/28.3 ms`（R15）compressed-state 诊断仅保留在不可变旧 artifacts 中作溯源，不再显示为主计时。v3 不测量 256-token 生成吞吐；该列继续来自历史生成评测。按相同保留率对照，展示 resize p25/p50/p75 分别对应 DivPrune p25/p50/p75：DivPrune 在 L28 的分类与 gold PPL 更高或相近；R15 约 25% 保留时 resize 的 macro 略高但 accuracy 更低，约 50%/75% 时 DivPrune 的 accuracy 与 macro 均更高。这些均是固定清单观察，不外推为跨任务方法排序。

`derived/xguard_attr_lgw_*_resize_*_1k_lightweight.json` 保存历史下采样生成评测的逐样本类别、错误、原始/目标图像尺寸、视觉 token、PPL 与时延字段；v3 timing raw/summary 独立保存计时、尺寸、视觉 token 与 token ID。`derived/xguard_attr_failure_records_1k.json` 仍是此前生成的 17 条件 × 1,000 条记录，可按 `sample_id` 与固定 manifest 连接；它不包含 timing-only v3，也不包含本次补齐的三个 R15 canonical 单次前向 FastV 条件。完整归因、token、log-prob 与历史生成时延仍在各质量 raw JSON。按展示的 resize p25/p50/p75 顺序，新增错误数为 L28 `44/58/79`、R15 `45/59/91`，同时有 L28 `30/31/29`、R15 `24/25/26` 个基线错误翻转为正确，不能把 aggregate 差值解读为同一批样本的单向退化。

### 与来源实验对比

L28_full 的 attr accuracy/macro 为 `0.616/0.433`，来源单 token 任务为 `0.620/0.413`，即 accuracy `−0.004`、macro `+0.020`，支持 H1 的同口径比较。更深的条件同时改变了训练目标和层删除计划；其中 attr R15 的 `[24, 25, 26, 27]` 与来源 R15 的 `[3, 4, 26, 27]` 不同，故不能把同名 R15/R30/R45 的差值归因于单一因素。当前比较只保留各自实验内的 Ghost 与 Token 剪枝差分。

### 假设判定

**H1（首 token 质量保持）**：✅ **通过**。L28_full accuracy=0.616 vs 来源 0.620，差值 −0.004，在 −0.02 容差内。macro recall 0.433 甚至略高于来源 0.413。说明 attr adapter 在完整输出训练后，首 token 分类能力没有显著损失。

**H2（Ghost 恢复收益）**：✅ **通过**。所有三个剪枝率下 ghosted > pruned：R15 +0.121、R30 +0.327、R45 +0.318（accuracy Δ）。R45 pruned 完全崩溃（acc=0）但 R45 ghosted 恢复到 0.318。由于 attr 与来源实验的同名剪枝率使用不同删除层，恢复量级仅作各实验内比较，不作跨实验排序。

**H3（归因拟合质量）**：⚠️ **部分通过**。L28_full gold PPL=5.28 < 8 阈值，通过。但 R45 ghosted gold PPL=142.14 / L28_full 5.28 = **26.9×**，远超 1.5× 阈值。Ghosted 层恢复了分类能力（H2），但归因文本质量无法通过线性近似恢复。

**H4（置信度一致性）**：❌ **未通过**。L28_full 下 gold PPL − self PPL = 5.28 − 1.82 = **3.46**，超过 2.0 阈值。模型在自身生成上远比在 teacher 参考文本上更自信（self NLL=0.60 vs gold NLL=1.62），这反映 attr 模型学到了与 teacher 不同的归因风格分布。剪枝加深时差值方向不确定（R15 ghosted 3.00、R30 ghosted 31.28、R45 ghosted 139.80），但 R45 下 gold PPL 急剧恶化而 self PPL 仍低。

**H5（吞吐）**：❌ **未通过**。L28_full 完整生成吞吐=0.279 rps，远低于 1.0 阈值；单次前向 FastV 的 256-token generate-call RPS 虽升至 L28 `0.319/0.327/0.345`、R15 `0.270/0.274/0.294`，仍不满足该完整生成目标。以 canonical 全口径首 token P50 的倒数作近似，FastV p25/p50/p75 为 L28 `8.3/8.7/9.3` rps、R15 `8.7/9.1/9.6` rps，高于未压缩 L28/R15 的 `7.6/8.0` rps；它只描述单请求首 token 成本，不能替代 H5 的完整生成吞吐。

### 核心发现

1. **分类→生成的迁移代价极小**：仅改训练目标（首 token → 完整输出），首 token 分类 accuracy 损失仅 0.004（H1 通过），同时模型获得了输出完整归因段落的能力。
2. **层计划必须考虑生成敏感性**：Attr adapter 的梯度打分将尾部层（24–27）评为最不重要，但删除它们后的归因 PPL 明显恶化，说明该分数不能单独代表生成保真度。早期/尾部混合计划是否更稳健仍是需要在同一 attr 训练与评测协议下控制验证的假设。
3. **Ghost 恢复在生成任务上效果有限**：Ghost 能恢复分类能力（H2 通过），但 gold PPL 恢复不完整——R15 ghosted 16.15 vs L28_full 5.28（3× 差距），R45 ghosted 142.14（27× 差距）。线性近似不足以恢复非线性文本生成所需的高阶表征。
4. **Self-PPL 不是可靠的归因质量代理**：self PPL 在所有条件下都保持在 1.5–2.3 的低范围，即使 gold PPL 已恶化 100×。模型对自身生成的错误文本同样自信。
5. **生成吞吐与分类不可比**：完整生成 0.28 rps 是分类 5.0 rps 的 1/18，由任务性质决定，非算法瓶颈。

## 局限与证据边界

- 单一训练 seed、单一 256 条校准样本和单一 1,000 条评测子集；17 类在评测集中无支持，低频类波动极大，没有跨 seed 方差或统计显著性结论。
- 评测集参考归因来自 full eval JSONL 的 `pred_reason`（teacher 模型输出），不是人工标注；gold PPL 的绝对值受 teacher 写作风格影响，跨实验可比但不可解读为"人类可读性"。
- 训练时过滤 2 条空归因样本但不改动评测集；评测中仍可能出现模型只输出 letter 或 EOS 的情况，此类样本归入 `self_attr_ppl.status="empty_generation"`。
- on-generation PPL 使用 greedy 生成时的每步 log-prob，与 teacher-forcing PPL 的参考序列不同；二者绝对值差异同时包含"分布偏移"和"参考文本不同"两个来源，不能单独归因。
- 完整生成使用 `use_cache=true` 与来源实验的 `use_cache=false` 协议不同，因此首 token 时延单独以 `use_cache=false` 重测（`first_token_ms`），保证跨实验可比；`total_generate_ms` 只用于本实验内部条件比较。
- v3 resize `full_path_ttft_ms` 与 v2 共享 ready-input 起点，但作为独立运行只计入缩图后视觉编码和一-token生成；缩图/传输在单列 `processor_ms`，既不代表完整请求 TTFT，也不代表 256-token 生成吞吐。
- 计时是单卡、batch=1、单请求顺序测量；不代表连续组批、服务并发或功耗。

## 关联实体

- 来源实验（同模型、同数据、单 token 分类）：[[LLM-Wiki/experiments/20260902-xguard-ghosted-layer-recovery/README.md]]
- XGuard 数据、LoRA 与视觉 token 剪枝：[[LLM-Wiki/experiments/20260901-xguard-multiclass-vistok/README.md]]
- VLGuard Ghosted Layers 来源实验：[[LLM-Wiki/experiments/20260901-ghosted-layer-recovery/README.md]]
- 研究项目：[[LLM-Wiki/research/safety-classifier-compression/overview.md]]
- 方法来源：[[LLM-Wiki/raw/sources.yaml|paper-yun-2026-ghosted-layers]]
