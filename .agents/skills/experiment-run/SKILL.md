---
name: experiment-run
description: Plan, run, reproduce, benchmark, ablate, debug, or analyze a research experiment while preserving configurations, raw outputs, failures, and evidence in the Contrail LLM Wiki.
---

# Experiment Run

1. Read LLM-Wiki/metadata/workflows/common-contract.md.
2. Read and follow LLM-Wiki/metadata/workflows/experiment-run.md.
3. Inspect the relevant project, paper notes, concepts, existing experiments, code state, data, and available compute.
4. Before execution, make the hypothesis, baseline, variables, metrics, success criteria, budget, and stopping condition explicit.
5. Record the actual environment, commands, versions, seeds, and configuration. Do not overwrite raw outputs.
6. Preserve failed, interrupted, OOM, and negative runs with status and cause.
7. Separate raw results, derived metrics, statistical inference, and interpretation.
8. Do not expand cost, download restricted data, or mutate external systems without authorization.
9. Link conclusions to the exact run and update hypotheses or motivation only to the degree supported.
10. Finish with the wiki-finalize procedure and run its validator.
