# PLAN: Exclude tune-only SiFive series from the CPU report

## Status

- Overall: complete.
- Current phase: complete — artifacts regenerated and compared.
- Phase 1 evidence confirms the exact aliases for the current configured toolchain matrix; implementation and targeted validation are complete.

## Objective

Correct the generation of `mcpu_lists/compiler-mcpu.csv` so SiFive names accepted only by Clang's `-mtune` are not marked as supported `-mcpu` values. Regenerate the current CSV and workbook through the corrected generator.

## Findings and evidence limits

- `extract_clang_mcpu_values()` in `parse_mcpu_values.sh` treats every name under "Available CPUs for this target:" as an accepted `-mcpu` value. The user reports that this help catalog includes tune-only SiFive aliases. A separate `-mtune` section leaking into the parser has not been established.
- `gen_compiler_mcpu.sh` reuses existing `mcpu_list.csv` files unless `--force` is supplied. Fixing extraction alone therefore cannot correct comparisons regenerated from saved data.
- The current aggregate contains the following nine candidate aliases, with blank GCC columns. These observations establish the affected rows, not whether each alias is tune-only in every version:

  `sifive-6-series`, `sifive-7m-series`, `sifive-7n-series`, `sifive-7o-series`, `sifive-7-series`, `sifive-8-series`, `sifive-p400-series`, `sifive-p500-series`, `sifive-p600-series`.

- GCC extraction reads its own `-mcpu` section and looks for a following `-mtune` heading. No equivalent GCC problem is demonstrated by the saved data; live GCC behavior has not been tested.

## Decisions and acceptance criteria

1. **Confirm exclusions before applying them.** For candidate aliases, use minimal compilations with appropriate RISC-V target/ISA/ABI settings to establish rejection by `-mcpu` and acceptance by `-mtune`, or inspect authoritative target definitions for the relevant toolchain versions. Record compiler/source versions and diagnostics. Do not classify an alias from its spelling or blank GCC cells alone. If evidence is unavailable, record the unresolved aliases rather than silently excluding them.
2. **Use one classification policy.** Keep confirmed exclusions in one shared exact-name classifier used by extraction and aggregation. If evidence shows version-dependent behavior, scope the policy to those versions before implementation. Avoid a blanket `sifive-*-series` exclusion that could hide future CPU names.
3. **Filter Clang support specifically.** Extraction omits confirmed tune-only aliases. Aggregation clears their Clang marks from saved version data while preserving any GCC marks. Omit a row only when every support cell is empty after this correction.
4. **Preserve valid CPUs.** Concrete names such as `sifive-e76n`, `sifive-s76n`, `sifive-u74n`, `sifive-p270n`, and `sifive-x280n` retain their existing support marks. All unaffected rows and version columns remain equal to the original data.
5. **Regenerate artifacts.** Produce `compiler-mcpu.csv` using the corrected generator and `compiler-mcpu.xlsx` using its existing conversion step. Do not hand-edit the aggregate as the implementation of the fix.

## Scope and guardrails

- Preserve unrelated working-tree changes; do not commit without a commit request.
- Keep GCC extraction behavior and support data intact.
- Keep existing version CSV snapshots intact in this task. The aggregation correction must work with these saved files, which can still contain the original misleading Clang marks. Future extraction uses the corrected policy.
- Do not add a separate tuning report, upgrade dependencies, or refresh unrelated compiler data.
- Use installed compilers or relevant source definitions for classification. Do not load modules merely to regenerate the aggregate.
- The repository has no PDF generation step. `mcpu_lists/compiler-mcpu.pdf` is outside this change; explicitly report that it remains stale after the CSV/workbook correction.
- Put temporary evidence, fixtures, and compiler outputs under `/tmp`. Do not add repository test files for this task.

## Phases and validation

### Phase 1: Confirm the affected aliases

- [x] Review the extractor, aggregation, cached-data behavior, configured versions, and workbook generation.
- [x] Revise the plan to distinguish observed rows from confirmed target capabilities.
- [x] Confirm the exact exclusions for the configured toolchain versions and record the evidence here.
- [x] Finalize the shared classifier and any required version scoping from that evidence.

Validation: direct compiler acceptance results or authoritative versioned definitions. Saved report cells alone do not satisfy this phase.

Phase 1 evidence (2026-11-09): probed the installed Clang binaries for all configured versions in `toolchain_config.sh`: 3.1.5 (LLVM-Metal/Clang 18.9.1), 4.0.5, 4.0.6, 4.1.0, 4.2.5, 4.2.6 (LLVM-Metal/Clang 20.9.0), and 5.0.2, 5.0.3 (LLVM-Metal/Clang 21.9.0). Each probe used `-target riscv64-unknown-elf -march=rv64gc -mabi=lp64d -fsyntax-only -x c /dev/null`.

| Alias | In `-mcpu=help` | `-mcpu` result | `-mtune` result |
|---|---|---|---|
| `sifive-6-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-7m-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-7n-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-7o-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-7-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-p400-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-p500-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-p600-series` | all 8 versions | rejected in all 8 | accepted in all 8 |
| `sifive-8-series` | 3.1.5 only | rejected in all 8 | accepted in 3.1.5; rejected in later versions |

For example, Clang 5.0.3 reports `unsupported argument 'sifive-p400-series' to option '-mcpu='` and exits 1 for `-mcpu=sifive-p400-series`; the same command with `-mtune=sifive-p400-series` exits 0. `sifive-8-series` is absent from the `-mcpu=help` catalog for 4.0.5 through 5.0.3, so its later `-mtune` rejection does not affect extraction. This confirms the nine exact exclusions for the configured matrix; no suffix or family wildcard is warranted. Keep the shared policy exact-name based for these configured toolchains and revalidate it when adding toolchain versions.

### Phase 2: Fix extraction and aggregation

#### Phase 2A: Shared policy and Clang extraction (Sequential)

- [x] Add the exact-name classifier in `mcpu_target_policy.sh`, with a comment explaining why the help catalog is insufficient.
- [x] Apply the classifier to Clang extraction so both dump and CSV paths omit confirmed tune-only aliases while preserving concrete CPUs.

Validation: `bash -n` and temporary fake-Clang fixtures for dump and CSV paths passed; `git diff --check` passed. `shellcheck` is unavailable.

#### Phase 2B: Cached aggregation and report documentation (Sequential)

- [x] Apply the classifier to cached data when deriving Clang marks; preserve GCC cells and remove rows with no remaining support.
- [x] Search callers and document the corrected CPU-report semantics and cached snapshot behavior in the README.
- [x] Validate cached aggregation with temporary fixtures covering tune-only aliases, concrete CPUs, a synthetic GCC mark, and blank/no-support rows.

Validation: `bash -n`, `git diff --check`, and the temporary eight-version aggregation fixture passed. CSV checks confirmed tune-only Clang rows were omitted, synthetic GCC marks were retained, valid CPU marks were preserved, and blank/duplicate rows were absent. The fixture's XLSX data matched the CSV when generated with the available software-machine Python environment. `shellcheck` is unavailable.

### Phase 3: Regenerate, compare, and hand off

- [x] Confirm every version in `TOOLCHAIN_VERSIONS` has its saved `mcpu_list.csv`, and that the declared workbook dependencies are available.
- [x] Run `./gen_compiler_mcpu.sh` without `--force` from the repository root. With all configured caches present, its existing early return skips compiler/module processing and regenerates the aggregate and workbook.
- [x] Compare the generated CSV against the original by CPU name and column: all GCC cells and all unaffected Clang cells must match; only confirmed tune-only Clang marks may disappear. Verify headers, row widths, sorting, and unique nonempty CPU names.
- [x] Confirm workbook rows and support marks match the CSV. Check a second generation produces identical CSV content; compare workbook data rather than ZIP bytes.
- [x] Review the focused diff and record actual validation, unresolved evidence, and the stale version snapshots/PDF limitation.
- [x] Archive this plan in `plan-todo/done/` only when implementation and required checks are complete.
- [x] Update context and end session.

Phase 3 validation (2026-11-09): all eight configured versions (`3.1.5`, `4.0.5`, `4.0.6`, `4.1.0`, `4.2.5`, `4.2.6`, `5.0.2`, `5.0.3`) had saved `mcpu_list.csv` files. The documented software-machine environment supplied pandas 2.2.3 and openpyxl 3.1.2. Ran `./gen_compiler_mcpu.sh` twice without `--force`; each run skipped all cached per-version processing and regenerated the aggregate CSV and workbook. The generated CSV matched the baseline after removing 65 Clang marks for the nine confirmed aliases and dropping their nine unsupported rows. Headers, 17-column row widths, alphabetical sorting, unique nonempty CPU names, all GCC cells, and all unaffected Clang cells matched. The workbook's 88 data rows and 17 columns matched the CSV cell-for-cell. The second generation produced the same CSV (Git blob SHA-1 `145bb3267e1f68fa67741e55cc98f5f9ce0e5641`). Per-version snapshots were unchanged. No aliases remain unresolved for the configured matrix. The PDF was not regenerated and remains stale relative to the corrected CSV.

## Expected files

- `parse_mcpu_values.sh` — corrected Clang extraction.
- `gen_compiler_mcpu.sh` — correction when aggregating cached lists.
- A small shared policy helper, provisionally `mcpu_target_policy.sh`, if needed to avoid duplicating the exclusion list.
- `README.md` — CPU-report semantics and cached-data limitation.
- `mcpu_lists/compiler-mcpu.csv` and `mcpu_lists/compiler-mcpu.xlsx` — regenerated outputs.

## Review record

This revision replaces the unsupported blanket suffix rule with evidence-based exact exclusions, preserves GCC support during aggregation, adds reproducible regeneration and validation steps, and makes the workbook and historical-artifact handling explicit. Implementation, regeneration, CSV comparison, workbook consistency, and repeat-generation checks are complete. The corrected CSV and workbook are ready; historical per-version snapshots remain unchanged and the PDF remains stale.

## Context Snapshot

- **Current progress**: All phases complete; CSV and workbook regenerated and compared.
- **Previous phase outputs**: Phase 1 confirmed nine exact tune-only aliases across the configured versions. Phase 2 added the shared classifier, filtered Clang extraction and cached aggregate marks, retained GCC marks, omitted unsupported rows, and documented report semantics. Phase 3 regenerated the aggregate twice, confirmed identical CSV content, preserved every GCC and unaffected Clang cell, and matched workbook data to the CSV.
- **Known issues and blockers**: `mcpu_lists/compiler-mcpu.pdf` remains stale because no PDF generation step exists. Per-version snapshots remain unchanged by design. No aliases remain unresolved for the configured matrix.
- **Key files**: `mcpu_target_policy.sh`, `parse_mcpu_values.sh`, `gen_compiler_mcpu.sh`, `README.md`, `mcpu_lists/compiler-mcpu.csv`, and `mcpu_lists/compiler-mcpu.xlsx`.
- **Verification**: Phase 2 targeted shell/fixture checks passed. Phase 3 CSV comparison passed (65 tune-only Clang marks removed, nine unsupported rows omitted, all other support cells preserved); workbook data matched all 88 CSV data rows and 17 columns; repeat generation kept CSV SHA-1 `145bb3267e1f68fa67741e55cc98f5f9ce0e5641`.
- **Verified Tree Hash**: `8412ddeb0d241d60d45d8eb57398bb4e4ffdb459`.
- **Hash method**: The prescribed `git stash create` could not write the repository index in this read-only `.git` mount. The same tracked working-tree tree was computed using a copied temporary index and temporary object directory; untracked paths are omitted as they are by `git stash create`.
