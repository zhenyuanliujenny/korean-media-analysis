# Korean media exposure analysis
# Curated subset of the supplied dissertation R Markdown, not a full reproduction.
# Run from the repository root: Rscript R/analysis.R /path/to/authorized.csv
# Participant-level data is not distributed with this repository.
args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 1L) stop("Supply one authorized CSV path. See data/README.md.")
input_file <- args[[1]]
required_packages <- c("tidyverse", "car")
missing_packages <- required_packages[!vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing_packages)) stop("Install required packages first: ", paste(missing_packages, collapse = ", "))
library(tidyverse)
library(car)
dir.create("results", showWarnings = FALSE)
# The first two rows are removed to match the source export. Do not use this
# rule with another export layout without checking its metadata rows first.
raw <- read_csv(input_file,  show_col_types = FALSE)
raw <- raw[-c(1, 2), ]
cat("Raw rows:", nrow(raw), "\n\n")

df <- raw %>%
  mutate(across(c(Progress, Age, score, VocabScore, SpeakerIdentity, Phonology), as.numeric),
         EndDate_dt = as.POSIXct(EndDate))

n0 <- nrow(df)

# Step 1: Keep matched rows only
df <- df %>% filter(match_status == "matched")
n1 <- nrow(df)

# Step 2: Remove pre-launch data (before Feb 14)
df <- df %>% filter(EndDate_dt >= as.POSIXct("2026-02-14 00:00:00"))
n2 <- nrow(df)

# Step 3: Remove duplicate answer profiles
exclude_cols <- c("StartDate","EndDate","RecordedDate","ResponseId","Duration (in seconds)",
                  "Q_BallotBoxStuffing","PARTICIPANT_ID","VocabScore","SpeakerIdentity",
                  "Phonology","task_total_score","task_datetime","time_diff_min",
                  "match_confidence","match_status","EndDate_dt")
df <- df %>% distinct(pick(all_of(setdiff(names(df), exclude_cols))), .keep_all = TRUE)
n3 <- nrow(df)

cat("=== Cleaning Summary ===\n")
cat("Raw:", n0, "\n")
cat("Step 1 - Matched only:", n1, "(removed", n0-n1, ")\n")
cat("Step 2 - From Feb 14:", n2, "(removed", n1-n2, ")\n")
cat("Step 3 - Deduplicated:", n3, "(removed", n2-n3, ")\n")

lower_bounds <- c(Q463_1=12, Q487_1=12, Q487_2=16, Q488_1=12, Q488_2=16, Q488_3=21,
  Q489_1=10, Q489_2=18, Q489_3=26, Q489_4=33, Q490_1=10, Q490_2=18, Q490_3=31, Q490_4=46,
  Q491_1=10, Q491_2=18, Q491_3=31, Q491_4=46, Q491_5=60)

upper_bounds <- c(Q463_1=15, Q487_1=15, Q487_2=20, Q488_1=15, Q488_2=20, Q488_3=30,
  Q489_1=17, Q489_2=25, Q489_3=33, Q489_4=40, Q490_1=17, Q490_2=30, Q490_3=45, Q490_4=60,
  Q491_1=17, Q491_2=30, Q491_3=45, Q491_4=60, Q491_5=99)

q_groups <- list(Q463="Q463_1", Q487=c("Q487_1","Q487_2"), Q488=c("Q488_1","Q488_2","Q488_3"),
  Q489=c("Q489_1","Q489_2","Q489_3","Q489_4"), Q490=c("Q490_1","Q490_2","Q490_3","Q490_4"),
  Q491=c("Q491_1","Q491_2","Q491_3","Q491_4","Q491_5"))

freq_recode <- c("每天 Every day"=5, "至少每周一次 At least once a week"=4,
  "至少每月一次 At least once a month"=3, "少于每月一次 Less than once a month"=2, "从不 Never"=NA_real_)
freq_to_days <- c(`5`=365, `4`=104, `3`=24, `2`=6)

for (mc in names(lower_bounds)) df[[paste0(mc,"_num")]] <- freq_recode[df[[mc]]]

df$q_group <- sapply(df$Age, function(a) {
  if (is.na(a)) NA_character_ else if (a<=15) "Q463" else if (a<=20) "Q487"
  else if (a<=30) "Q488" else if (a<=40) "Q489" else if (a<=60) "Q490" else "Q491"
})

sa <- aw <- ed <- numeric(nrow(df))
for (i in 1:nrow(df)) {
  grp <- df$q_group[i]; ai <- df$Age[i]
  if (is.na(grp)) { sa[i] <- aw[i] <- ed[i] <- NA; next }
  cols <- q_groups[[grp]]; freqs <- as.numeric(df[i, paste0(cols,"_num")]); names(freqs) <- cols
  af <- freqs[!is.na(freqs)]
  if (length(af)==0) { sa[i] <- aw[i] <- ed[i] <- NA; next }
  sa[i] <- lower_bounds[names(af)[1]]; aw[i] <- mean(af)
  lc <- cols[length(cols)]; td <- 0
  for (cn in names(af)) {
    bu <- if(cn==lc) min(upper_bounds[cn], ai) else upper_bounds[cn]
    td <- td + freq_to_days[as.character(af[cn])] * max(bu - lower_bounds[cn] + 1, 1)
  }
  ed[i] <- td
}
df$starting_age <- sa; df$years_watching <- pmax(df$Age - sa, 0)
df$avg_watching_score <- aw; df$estimated_days <- ed

df$formal_yn <- factor(ifelse(grepl("No|没有", df$Formallearning), "No", "Yes"), c("No","Yes"))
df$formal_yn[is.na(df$Formallearning)] <- NA
df$heritage_yn <- factor(ifelse(grepl("没有|从不|No, never", df$Heritage1), "No", "Yes"), c("No","Yes"))
df$heritage_yn[is.na(df$Heritage1)] <- NA
df$selfstudy_yn <- factor(ifelse(grepl("没有|None", df$Selfstudy), "No", "Yes"), c("No","Yes"))
df$selfstudy_yn[is.na(df$Selfstudy)] <- NA
df$gender_simple <- factor(case_when(grepl("Female|女",df$Gender)~"Female", grepl("Male|男",df$Gender)~"Male", TRUE~"Other"))
df$exposed <- factor(ifelse(!is.na(df$starting_age), "Exposed", "Not exposed"), c("Not exposed","Exposed"))

# Unified sample: remove missing controls
n_pre <- nrow(df)
df <- df %>% filter(!is.na(formal_yn), !is.na(heritage_yn), !is.na(selfstudy_yn))

# Full-sample exposure variables (non-exposed = 0)
df <- df %>% mutate(
  years_watching_full = ifelse(is.na(years_watching), 0, years_watching),
  avg_watching_full   = ifelse(is.na(avg_watching_score), 0, avg_watching_score),
  estimated_days_full = ifelse(is.na(estimated_days), 0, estimated_days))

cat("=== Unified Analytic Sample ===\n")
cat("After control filter:", n_pre, "->", nrow(df), "\n")
cat("Exposed:", sum(df$exposed=="Exposed"), "| Not exposed:", sum(df$exposed=="Not exposed"), "\n")
# Preserve the source model coding: binary controls use -1/+1 effect coding.
for (v in c("formal_yn", "heritage_yn", "selfstudy_yn")) {
  contrasts(df[[v]]) <- matrix(c(-1, 1), ncol = 1,
                             dimnames = list(levels(df[[v]]), "Yes"))
}
df_exp <- df %>% filter(exposed == "Exposed")
# Welch test; pooled-SD Cohen's d, matching the source report.
t_h3 <- t.test(score ~ exposed, data = df)
e <- df$score[df$exposed == "Exposed"]
n <- df$score[df$exposed == "Not exposed"]
pooled_sd <- sqrt(((length(e)-1)*var(e)+(length(n)-1)*var(n))/(length(e)+length(n)-2))
cohens_d <- (mean(e)-mean(n))/pooled_sd
# F1: Years of watching only
f1 <- lm(score ~ years_watching_full, data=df)

# F2: + avg watching frequency
f2 <- lm(score ~ years_watching_full + avg_watching_full, data=df)

# F3: + control variables
f3 <- lm(score ~ years_watching_full + avg_watching_full +
           formal_yn + heritage_yn + selfstudy_yn, data=df)

cat("=== Model F1 ===\n"); summary(f1)
cat("\n=== Model F2 ===\n"); summary(f2)
cat("\n=== Model F3 (Full model) ===\n"); summary(f3)

f5 <- lm(score ~ scale(Age) * scale(years_watching_full) +
           scale(avg_watching_full) + formal_yn + heritage_yn + selfstudy_yn, data=df)
cat("=== Model F5: Age x Years of Watching ===\n"); summary(f5)

m1 <- lm(score ~ starting_age, data=df_exp)
m2 <- lm(score ~ starting_age + years_watching + avg_watching_score, data=df_exp)
m3 <- lm(score ~ starting_age + years_watching + avg_watching_score +
           formal_yn + heritage_yn + selfstudy_yn, data=df_exp)

cat("=== Model 1 ===\n"); summary(m1)
cat("\n=== Model 2 ===\n"); summary(m2)
cat("\n=== Model 3 ===\n"); summary(m3)
# Save aggregate outputs only; do not export participant-level rows.
models <- list(F1=f1, F2=f2, F3=f3, F5=f5, M1=m1, M2=m2, M3=m3)
model_comparison <- purrr::imap_dfr(models, function(m, name) {
 tibble(model=name, n=nobs(m), r_squared=summary(m)$r.squared,
        adjusted_r_squared=summary(m)$adj.r.squared)
})
write_csv(model_comparison, "results/model_comparison.csv")
capture.output({
 print(t_h3); cat("Pooled-SD Cohen's d:", cohens_d, "\n")
 print(anova(f1,f2,f3)); print(anova(m1,m2,m3))
 print(car::vif(m3)); print(sessionInfo())
}, file="results/tests_and_session.txt")
for (name in names(models)) {
 capture.output(summary(models[[name]]), file=file.path("results",paste0(name,".txt")))
}
plot <- ggplot(df, aes(x=exposed,y=score,fill=exposed)) +
 geom_boxplot(outlier.shape=NA) +
 scale_fill_manual(values=c("Not exposed"="#A0AAB4","Exposed"="#197C80")) +
 labs(x=NULL,y="Composite task score",title="Task scores by media exposure group") +
 theme_minimal(base_size=12) + theme(legend.position="none")
ggsave("results/exposure_scores.png",plot,width=7,height=4,dpi=200)
cat("Aggregate results saved under results/. Check outputs before publishing.\n")
