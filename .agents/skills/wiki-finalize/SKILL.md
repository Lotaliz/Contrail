---
name: wiki-finalize
description: Finalize and validate any change to the Contrail LLM Wiki by checking metadata, sources, links, dates, indexes, reading levels, and dated change records. Use after another workflow edits the Wiki or when asked to audit its consistency.
---

# Wiki Finalize

1. Read LLM-Wiki/metadata/workflows/wiki-finalize.md.
2. Determine affected files from the current task's operations and explicit scope. Preserve unrelated user changes.
3. Do not inspect or invoke Git. Git status, diff, history, staging, and commits belong exclusively to the user.
4. Complete required source registry, metadata, dates, links, indexes, and the dated CHANGELOG entry.
5. Use exactly:
   - Date heading: ## YYYY-MM-DD
   - Entry: - [Type] [scope] one-sentence result.
6. Create a detailed changes note only when the workflow criteria require it.
7. Run:
   powershell -NoProfile -ExecutionPolicy Bypass -File .agents/skills/wiki-finalize/scripts/validate-wiki.ps1
8. Fix errors caused by the current task. Do not silently rewrite content that requires research judgment.
9. Report remaining warnings, created files, modified files, evidence gaps, and human decisions.

The validator is deterministic, read-only, and independent of Git. It supplements semantic review; it does not prove that a paper interpretation or experimental conclusion is correct.
