# PLAN: Filter non-SiFive vendor CPUs from the MCPUs report

## Status
- Overall: complete
- Current phase: complete — policy applied and report regenerated

## Objective
Keep non-SiFive vendor CPU names out of fresh extraction and the aggregate report.

## Decisions and acceptance criteria
- Filter names with the listed vendor prefixes: `andes`, `mips`, `spacemit`, `syntacore`, `thead`, `tt`, `veyron`, and `xiangshan`.
- Also filter `rp2350-*`, which appears in the current report as the Raspberry Pi `rp2350-hazard3` target.
- Match vendor prefixes only at CPU-name boundaries; preserve the existing SiFive tune-only filter.
- Regenerate the aggregate CSV and workbook; preserve existing version snapshots unless forced.

## Guardrails
Preserve the existing uncommitted tune-only filtering changes and unrelated working-tree edits. Do not run test suites unless requested.

## Files
- `mcpu_target_policy.sh`, `parse_mcpu_values.sh`, `gen_compiler_mcpu.sh`, `README.md`
- `mcpu_lists/compiler-mcpu.csv`, `mcpu_lists/compiler-mcpu.xlsx`

## Phases
### Phase 1: Implement and refresh report
- [x] Add the shared vendor policy and apply it to fresh extraction and cached aggregation.
- [x] Document the report filtering behavior.
- [x] Regenerate and review the CSV and workbook.
- [x] Archive this plan and update context to end the session.
