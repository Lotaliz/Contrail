---
id: change-2026-09-24-cleanup-unread-raw-and-superseded-plans
type: change
title: "清理临时文件、未精读论文副本与过时研究方案"
tags: [change, research, visual-token-pruning, source]
date: 2026-09-24
change_type: Removed
status: active
---

# 清理记录

依据用户指定的三项范围，删除以下 54 个文件。论文删除依据为 paper-note 的 `reading_level` 不含 `deep-read`；`paper-ji-2026-vispco` 虽无现存独立笔记，但 2026-08-25 的变更记录明确记载升级精读，因此保留。保留所有精读论文副本、原有论文笔记、实验记录与阅读日志。

来源题录和 source ID 保留在 `raw/sources.yaml`，删除副本的 `local_path` 置空；既有 `sha256` 作为已删除原件的历史校验值保留。失效的 Wiki 链接改向现行方案或本清理记录。当前唯一研究方案为 [[LLM-Wiki/changes/2026-10-20-resolution-plan-and-superseded-ideas-cleanup.md|短政策条件下的文本政策指导视觉 Token 剪枝（历史方案，已删除）]]。

## 临时文件（22）

- `tmp/pdfs/quietprune/page-1.txt`
- `tmp/pdfs/quietprune/page-2.txt`
- `tmp/pdfs/quietprune/page-3.txt`
- `tmp/pdfs/quietprune/page-4.txt`
- `tmp/pdfs/quietprune/page-5.txt`
- `tmp/pdfs/quietprune/page-6.txt`
- `tmp/pdfs/quietprune/page-7.txt`
- `tmp/pdfs/quietprune/page-8.txt`
- `tmp/pdfs/quietprune/quietprune.txt`
- `tmp/pdfs/quietprune/render-04.png`
- `tmp/pdfs/quietprune/render-05.png`
- `tmp/pdfs/quietprune/render-06.png`
- `tmp/pdfs/quietprune/render-07.png`
- `tmp/pdfs/quietprune/render-08.png`
- `tmp/pdfs/safeatlas-vl-audit/distribution-36.png`
- `tmp/pdfs/safeatlas-vl-audit/distribution-37.png`
- `tmp/pdfs/safeatlas-vl-audit/distribution-38.png`
- `tmp/pdfs/safeatlas-vl-audit/page-03.png`
- `tmp/pdfs/safeatlas-vl-audit/page-04.png`
- `tmp/pdfs/safeatlas-vl-audit/page-05.png`
- `tmp/pdfs/safeatlas-vl-audit/page-06.png`
- `tmp/pdfs/safeatlas-vl-audit/paper.txt`

## 未精读的论文及派生文件（28）

- `LLM-Wiki/raw/papers/2020-lin-autoregressive-kd.pdf`
- `LLM-Wiki/raw/papers/2022-jiang-trips.pdf`
- `LLM-Wiki/raw/papers/2023-chang-stvit-supplement.pdf`
- `LLM-Wiki/raw/papers/2023-chang-stvit-supplement.txt`
- `LLM-Wiki/raw/papers/2023-chang-stvit.pdf`
- `LLM-Wiki/raw/papers/2023-chang-stvit.txt`
- `LLM-Wiki/raw/papers/2024-agrawal-sarathi-serve.pdf`
- `LLM-Wiki/raw/papers/2024-cai-matryoshka-mm.pdf`
- `LLM-Wiki/raw/papers/2024-chen-fastv.pdf`
- `LLM-Wiki/raw/papers/2024-gu-minillm.pdf`
- `LLM-Wiki/raw/papers/2024-ko-distillm.pdf`
- `LLM-Wiki/raw/papers/2024-wang-qwen2-vl.pdf`
- `LLM-Wiki/raw/papers/2024-yao-deco.pdf`
- `LLM-Wiki/raw/papers/2025-alvar-divprune.pdf`
- `LLM-Wiki/raw/papers/2025-bai-qwen3-vl.pdf`
- `LLM-Wiki/raw/papers/2025-ko-distillm2.pdf`
- `LLM-Wiki/raw/papers/2025-wen-right-problem.pdf`
- `LLM-Wiki/raw/papers/2025-yang-visionthink.pdf`
- `LLM-Wiki/raw/papers/2025-zhang-sparsevlm.pdf`
- `LLM-Wiki/raw/papers/2025-zhu-nanoflow.pdf`
- `LLM-Wiki/raw/papers/2026-jang-veto-opd.pdf`
- `LLM-Wiki/raw/papers/2026-liao-vtc-bench.pdf`
- `LLM-Wiki/raw/papers/2026-wang-metacompress.pdf`
- `LLM-Wiki/raw/papers/2026-wang-metacompress.txt`
- `LLM-Wiki/raw/papers/2026-yu-prism.pdf`
- `LLM-Wiki/raw/papers/2026-zhang-prefix-opd.pdf`
- `LLM-Wiki/raw/papers/2026-zhang-security-pitfalls-token-compression.pdf`
- `LLM-Wiki/raw/papers/2608.29098v1.pdf`

## 过时方案相关文档（4）

- `LLM-Wiki/research/visual-token-pruning/research-plan.md`
- `LLM-Wiki/research/visual-token-pruning/long-policy-bottleneck-pivot-assessment.md`
- `LLM-Wiki/research/visual-token-pruning/motivation.md`
- `LLM-Wiki/research/visual-token-pruning/gaps.md`

## 校验边界

清理前 Wiki 校验通过，存在两项原有警告：XGuard 实验记录中一条未解析 WikiLink，以及 2026-08-25 详细变更说明未从 CHANGELOG 链接。本次清理不修改这两项独立问题。
