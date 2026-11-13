# Data access and input requirements

Participant-level data is not included. The static report can be read without data. Running the R script requires a separately authorized source export with the same schema and metadata-row layout as the dissertation export.

## Core fields

| Fields | Use |
|---|---|
| `match_status`, `EndDate` | Keep matched records collected from 2026-02-14 onward |
| `Age`, `score` | Age and composite outcome |
| `VocabScore`, `SpeakerIdentity`, `Phonology` | Task scores; converted to numeric |
| `Progress` | Numeric export field |
| `Formallearning`, `Heritage1`, `Selfstudy` | Bilingual response strings used to construct controls |
| `Gender` | Descriptive category only; not a predictor in the curated models |
| `Q463_1`; `Q487_1`–`Q487_2`; `Q488_1`–`Q488_3`; `Q489_1`–`Q489_4`; `Q490_1`–`Q490_4`; `Q491_1`–`Q491_5` | Age-band exposure frequency responses |

The deduplication rule also expects all columns named in `exclude_cols` in `R/analysis.R`. These export metadata fields include response identifiers and timestamps. Do not distribute them as portfolio data. Additional answer fields can affect the source deduplication rule because it compares all columns not excluded.

The input CSV is not a generic tidy dataset: the first two rows after reading are assumed to be export metadata. Confirm the format before running. Response strings must match the source's English/Chinese recoding rules. Unexpected strings should be audited before using the models; the script intentionally does not redesign the original classification rules.

No mock participant data is included, and the project does not claim independent reproduction of the original estimates.
