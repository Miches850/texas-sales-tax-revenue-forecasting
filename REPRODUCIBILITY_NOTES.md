# Reproducibility Notes

The retained files are sufficient for a strong portfolio repository, but several items should be resolved before describing the project as fully reproducible.

1. The original Group 17 `.R` file was not retained; the available code is embedded in a submitted PDF and has been transcribed into an `.R` file for this repository.
2. The original `TXNA.xlsx` and `CPIAUCSL.xlsx` inputs used by the VAR model are missing.
3. The submitted code contains machine-specific Windows file paths; the portable version replaces them with repository-relative paths.
4. The code appendix includes a stray full-width parenthesis before `f_sales <- ...`; this is treated as a PDF/transcription artifact and omitted in the clean transcription.
5. The submitted code contains `install.packages()` calls. Those are not included in the portable workflow; package requirements are listed separately.
6. The report gives fiscal-year aggregation and BRE comparison totals, but the submitted code appendix does not show the aggregation/benchmark-comparison code. The reported totals are preserved under `outputs/reported_results/`.
7. The sales-tax holiday-adjustment code was supplied by the instructor/class and should remain attributed as such.
8. The project is a four-person group project; public publication of the full report/code should respect all coauthors.
9. The two historical revenue reference workbooks are retained, but the submitted R code does not directly use them.
