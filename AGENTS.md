# Contrail Research Agent Instructions

## Scope

These rules apply to the Contrail repository. The authoritative research procedures live under LLM-Wiki/metadata/workflows. Preserve raw sources, user-authored notes, experiment outputs, plugin settings, and unrelated changes.

## Mandatory routing

- A request to read, summarize, analyze, ingest, or compare a specific paper must use the paper-ingestion skill.
- A request to survey, research, find papers, map a field, identify trends, or derive research gaps must use the literature-review skill.
- A request to run, reproduce, benchmark, ablate, or analyze an experiment must use the experiment-run skill.
- A request to draft or revise academic prose, Related Work, motivation, methods, experiments, or a paper must use the academic-writing skill.
- Any task that changes LLM-Wiki must finish with the wiki-finalize skill and its validator.

If a task spans multiple workflows, use the smallest applicable sequence and share artifacts instead of duplicating them.

## Non-negotiable research rules

- Separate source material, source notes, reusable concepts, synthesis, motivation, and experiment evidence.
- Never present an LLM inference as a source claim. Label unsupported statements as hypotheses or TODOs.
- Never invent citations, bibliographic fields, measurements, experimental settings, or results.
- Keep raw files immutable. Store transformations as new files.
- Use stable IDs and the repository schema. Do not silently create new tags or document types.
- Preserve failed, interrupted, and negative experiments when they are informative.
- A research gap may enter motivation only when supported by multiple independent papers, direct experimental evidence, or an explicit scenario constraint.
- Do not overwrite unrelated user changes. Ask before destructive operations or materially changing the taxonomy.

## Change and Git boundary

- Record Wiki changes from the current task's actual semantic and structural effects, not from Git state.
- Follow the dated entry format defined in LLM-Wiki/metadata/workflows/wiki-finalize.md.
- Do not run Git status, diff, log, add, commit, restore, checkout, or other Git commands as part of a Wiki workflow.
- All Git inspection, staging, commits, and history management are performed manually by the user.

## Completion contract

Before reporting completion:

1. Run the applicable workflow completion checklist.
2. Run the Wiki validator.
3. Fix in-scope errors; report warnings that require judgment.
4. Update dates, indexes, source registry, and the dated CHANGELOG entry when required.
5. Report created files, modified files, evidence gaps, and remaining human decisions.
