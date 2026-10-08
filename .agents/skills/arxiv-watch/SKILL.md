---
name: arxiv-watch
description: Track recent arXiv papers for a Contrail research project with title/abstract relevance screening, a persistent lightweight index, and user-selected deep-read promotion. Use for recurring or manual recent-paper collection and candidate decisions; use literature-review for broad surveys and paper-ingestion for standalone paper analysis.
---

# arXiv Watch

Run from the Contrail repository. Default project: visual-token-pruning. Keep the authoritative procedure in LLM-Wiki; do not duplicate query strings or schemas here.

Read `LLM-Wiki/metadata/workflows/common-contract.md`, `LLM-Wiki/metadata/workflows/arxiv-watch.md`, the project's `overview.md`, and `watch/overview.md`. If the project has no watch configuration, establish its scope before collection rather than silently borrowing another project's queries.

Choose the mode from the user's request; scheduled runs always use **collect**.

## Collect

- Use the repository literature-review skill in discovered-only mode and follow the arxiv-watch workflow. Freeze the run cutoff, apply the configured rolling 10-day first-submission window, and obey the query/pagination/screening budget.
- Verify primary arXiv metadata, read titles and abstracts, and label relevance as the agent's screening judgment. This remains discovered / unverified, even if the abstract sounds persuasive.
- Deduplicate across query groups, all project candidates, the global source registry, and existing paper notes/logs. Reuse stable source IDs and existing notes. A changed arXiv version is the same paper.
- Register verified new sources and maintain one persistent candidate row per base arXiv ID. Retain out-of-scope and user-skipped/deferred records. Newly discovered direct/adjacent/uncertain candidates default to pending; out-of-scope rows are dedupe-only and carry no human decision state.
- Preserve the user's decisions. Do not create papers notes, execute selected-paper reading, download PDFs, or update synthesis/evidence merely because a scheduled run found candidates.
- Save the actual requests, coverage and unresolved IDs in a new batch log, including zero-new, partial and failed runs. Re-read affected files before writing so intervening user edits survive.
- Notify only for new direct/adjacent/uncertain candidates, important failures or necessary human judgment; keep unchanged/non-actionable runs quiet while retaining logs.

## Decide

Apply only decisions explicitly supplied by the user to identified direct/adjacent/uncertain candidate rows. Record the decision date and user basis. Do not infer selected from an agent relevance ranking. Out-of-scope rows have no decision state; move one into the active candidate table only when the user requests reconsideration. Keep every row; selection alone does not create a paper note or upgrade its reading level.

## Read selected papers

When the user explicitly requests reading named candidates or the selected list, use the repository paper-ingestion skill for each paper. Reuse its source ID and existing note, preserve user annotations, and create a project papers note only for a user-selected paper. Apply actual reading_level and verification. Mark ingested only after a completed deep-read note passes finalization; retain selected plus failure/partial-reading evidence otherwise.

For a standalone request to analyze or assess a named paper, route to paper-ingestion at the requested depth rather than forcing a recent-paper collection run.

## Finish

Use wiki-finalize for every Wiki mutation, including decision-only changes. Update affected dates, navigation and the dated CHANGELOG when the workflow requires it. Run the Wiki validator and manually check candidate-ID uniqueness, source references, preservation of user decisions and ingested-note depth; the existing validator does not check table business fields. Report actual files changed, coverage gaps, remaining warnings and human choices. Never invoke Git.
