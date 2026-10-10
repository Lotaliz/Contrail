# 实验目录

每个实验使用独立目录：`experiments/YYYYMMDD-short-name/`。

建议内容：

```text
YYYYMMDD-short-name/
├─ README.md        # 从 templates/experiment.md 复制
├─ data/            # 小型原始或处理后数据
├─ outputs/         # 模型输出与图表
└─ scripts/         # 可复现脚本（如需要）
```

所有结果说明应链接到对应研究项目的 `overview.md`；必要时再与相关论文笔记互链。

## 已登记的实验

- [[LLM-Wiki/experiments/20261010-cx-global-local-importance/README.md]]：用户报告新的自适应预算实验运行中；配置及结果尚未核验。

- [[LLM-Wiki/experiments/20261009-c5-nll-router-analysis/README.md]]

- [[LLM-Wiki/experiments/20261008-c5-policy-grounding/README.md]]

- [[LLM-Wiki/experiments/20260914-dual-evidence-token-compression/README.md]]
- [[LLM-Wiki/experiments/20260908-bidirectional-token-intervention/README.md]]
- [[LLM-Wiki/experiments/20260907-xguard-token-pruning-analysis/README.md]]
- [[LLM-Wiki/experiments/20260826-safety-pruning-finetuned/README.md]]
- [[LLM-Wiki/experiments/20260825-vispco-qwen25vl-small/README.md]]
- [[LLM-Wiki/experiments/20260825-safety-decoder-prune-kd-05b/README.md]]
- [[LLM-Wiki/experiments/20260825-safety-cascade-prune-kd-04b/README.md]]
- [[LLM-Wiki/experiments/20260825-safety-encoder-prune-kd-03b/README.md]]
