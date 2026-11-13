# Source outputs and provenance

The project uses the supplied `26March(fullmodelmain)-copy.Rmd` and the rendered analysis document `26March-fullmodelmain--copy.docx` (displayed report date 2026-04-03). The supplied DOCX is an analysis/code report, not assumed to be the complete dissertation narrative. Original files are retained separately and are not redistributed in this package.

## Output ledger

| Source output | Value used in the report |
|---|---|
| Cleaning summary | 485 → 386 matched → 374 post-launch → 367 deduplicated → 362 complete controls |
| Exposure counts | 239 exposed; 123 not exposed |
| H3 composite score | 12.00 vs 10.54; source t = -4.76, p = 2.93e-06; d = 0.477 |
| F3 | Viewing-frequency B = 0.27668, p = 0.01023; R² = 0.112 |
| F5 | Age × duration B = -0.49603, p = 0.000472; R² = 0.1427 |
| M3 | Starting-age B = -0.02474, p = 0.7293; R² = 0.1366 |
| M3 VIF | 1.159354, 1.117621, 1.079607, 1.348197, 1.086688, 1.349098 |

The sign of the source t-statistic follows its factor/group ordering. The exposed mean is higher. Cohen's d uses a pooled standard deviation while the test is Welch's t-test.

## Editorial changes to the code

The curated script retains source cleaning, variable construction, and selected F/M model formulas. It replaces the private absolute path with a command-line argument; removes inline dependency installation and duplicate exploratory blocks; explicitly expresses binary -1/+1 effect coding; and saves selected aggregate outputs and session information. It does not include every task-specific, estimated-days, residualized, or exploratory model in the original R Markdown.

The portfolio charts are generated from reported aggregate numbers, not reconstructed participant-level observations. No raw scatterplot, distribution, confidence interval, or model prediction has been fabricated.

## Validation

The R script was parsed successfully with R. It has not been executed against the source dataset; numerical equivalence and input compatibility remain unverified. Report figures and tables should be read as a presentation of supplied outputs, not a fresh replication.
