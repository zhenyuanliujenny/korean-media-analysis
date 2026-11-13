# Korean Media Exposure and Implicit Language Knowledge

An R-based statistical analysis portfolio adapted from a team dissertation.

**Zhenyuan Liu** · R · Data cleaning · Variable construction · Hypothesis testing · Hierarchical regression

## Overview

Does exposure to Korean media relate to implicit Korean language task performance, and does the age of first exposure help explain that relationship? This project uses survey and matched task data to examine exposure patterns, compare groups, and assess associations after accounting for formal learning, heritage background, and self-study.

## My contribution

I participated in data cleaning, variable construction, R analysis, and statistical modeling as part of the dissertation team. I also contributed to survey design and report writing. This portfolio presents shared project work and does not claim sole authorship of the study or code.

## Read the analysis

- [Project report with methods and selected results](docs/index.html) — download and open in a browser, or view through GitHub Pages after deployment.
- [Curated R analysis](R/analysis.R)
- [Data access and input requirements](data/README.md)
- [Source outputs and provenance](docs/provenance.md)

## What the analysis demonstrates

- Screening a 485-record export to a unified 362-person analytic sample.
- Matching eligibility, pilot exclusion, deduplication, missing-control filtering, and exposure-variable construction.
- Welch's t-test, pooled-SD Cohen's d, hierarchical linear models, nested-model comparisons, interaction terms, and VIF checks.
- Separating the full sample (N = 362) from the media-exposed subgroup (n = 239).
- Interpreting non-significant results and observational limitations alongside significant associations.

## Selected findings

These numbers are transcribed from the supplied rendered dissertation analysis; they were not recomputed for this portfolio.

| Analysis | Selected result | Interpretation |
|---|---|---|
| Exposure groups | Mean score 12.00 exposed vs 10.54 not exposed; Cohen's d = 0.477 | An unadjusted group difference, not a causal effect |
| Full-sample F3 | R² = 0.112; viewing-frequency coefficient 0.27668, p = 0.01023 | Frequency is associated with score conditional on the included predictors |
| Exposed-only M3 | Starting-age coefficient -0.02474, p = 0.7293 | This specification does not establish a starting-age association |
| Full-sample F5 | Standardized age × duration coefficient -0.49603, p = 0.000472 | Exploratory interaction; does not establish a critical period |

## Running the curated analysis

Requires R and packages `tidyverse` and `car`. Package versions are not pinned; no tested environment lockfile is supplied.

```r
install.packages(c("tidyverse", "car"))
```

From the repository root:

```sh
Rscript R/analysis.R /path/to/authorized/485_ScoreMatched.csv
```

The participant-level CSV is not included. The script preserves the source export assumptions, including dropping the first two metadata rows; it must not be applied blindly to differently structured data. Aggregate model outputs, tests, session information, and one plot are written to `results/`.

**Validation status:** R syntax was checked. End-to-end execution and numeric equivalence have not been verified because the source CSV was not supplied. The curated script covers selected core analyses, not every original exploratory model or figure.

## Limitations

The design is observational and includes retrospective self-reports. Starting age is inferred from age bands rather than exact dates. Frequency-to-days mappings are approximations (including 104 days/year for the weekly category and 24 for the monthly category). Non-exposure is represented by zero in full-sample exposure variables. Duplicate answer profiles are a heuristic and do not prove that two records belong to the same person. The before-18 cutoff is an analysis choice, not evidence of a biological threshold. The exposed-only and full-sample models address different populations. Multiple exploratory models were examined; individual p-values require that context.

## Data and attribution

No participant-level data is distributed. Data sharing depends on consent and applicable research permissions; public access is not assumed. The reported sample includes participants aged 12–70, so consent scope also needs checking before any record-level release. No open-source license has been assigned while team ownership and permission to publish the shared code are being confirmed.
