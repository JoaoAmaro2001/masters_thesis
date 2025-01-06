# -*- coding: utf-8 -*-
"""
paired_stats_epn_lpp_three_metrics.py

We have two CSV files:
  1) epn_table_long.csv  -> EPN data
  2) lpp_table_long.csv  -> LPP data

Each CSV has columns:
   Cond, Peak, Mean, Lat, Subject
 with Cond in ["Nat","Urb"], plus a "Subject" identifier.

We do:
 - "Peak" amplitude (peak amplitude)
 - "Mean" amplitude
 - "Lat" (peak latency)

Approach:
 1) Pivot wide for each metric to get columns [Nat, Urb].
 2) Check normality (Shapiro) on the difference (Nat - Urb).
 3) If normal => paired t-test (+ Cohen’s d).
    else => Wilcoxon signed-rank test.
 4) Store p-values, apply Bonferroni correction over 6 tests.
 5) Create boxplots of differences for each metric, for EPN & LPP.
 6) Print final summary.

@author: your_name
"""

import pandas as pd
import numpy as np
from scipy.stats import shapiro, ttest_rel, wilcoxon
import matplotlib.pyplot as plt

###############################################################################
# Configuration
###############################################################################
epn_csv = r"Z:\Exp_2-video_rating\results\analysis_erp_pipeline-esi_literature\group\data\epn_table_long.csv"
lpp_csv = r"Z:\Exp_2-video_rating\results\analysis_erp_pipeline-esi_literature\group\data\lpp_table_long.csv"

conditions = ["Nat","Urb"]   # We assume exactly 2
metrics    = ["Peak","Mean","Lat"]   # (peak amplitude, mean amplitude, peak latency)
component_labels = ["EPN","LPP"]     # We'll process EPN & LPP

###############################################################################
# Helper function for normality-based approach
###############################################################################
def paired_test(nat_series, urb_series):
    """Perform a normality-based paired test:
       - If difference is normal => paired t-test (plus Cohen’s d).
       - If difference is not normal => Wilcoxon. 
       Returns (test_type, stat, p, p_shapiro, effect_size).
         For Wilcoxon, effect_size is set to None (or could compute r).
    """
    df_clean = pd.concat([nat_series, urb_series], axis=1).dropna()
    x = df_clean.iloc[:, 0]
    y = df_clean.iloc[:, 1]
    diff = x - y
    w_stat, p_shapiro = shapiro(diff)
    if p_shapiro < 0.05:
        # Non-normal => Wilcoxon
        test_type = "Wilcoxon"
        stat, p_val = wilcoxon(x, y)
        eff_size = None  # We won't compute effect size here by default
    else:
        # Normal => Paired T-test
        test_type = "Paired t-test"
        stat, p_val = ttest_rel(x, y)
        # Cohen’s d for paired t-tests:  d = mean(diff) / std(diff)
        mean_diff = np.mean(diff)
        std_diff  = np.std(diff, ddof=1)
        eff_size  = np.nan
        if std_diff != 0:
            eff_size = mean_diff / std_diff
    return (test_type, stat, p_val, p_shapiro, eff_size)

###############################################################################
# Read data
###############################################################################
epn_df = pd.read_csv(epn_csv)
lpp_df = pd.read_csv(lpp_csv)

# Minimal check
needed_cols = {"Cond","Peak","Mean","Lat","Subject"}
for (df_comp, label) in [(epn_df,"EPN"), (lpp_df,"LPP")]:
    if not needed_cols.issubset(df_comp.columns):
        raise ValueError(f"{label} CSV must have columns {needed_cols}")

# Filter only Nat/Urb
epn_df = epn_df[epn_df["Cond"].isin(conditions)]
lpp_df = lpp_df[lpp_df["Cond"].isin(conditions)]

###############################################################################
# We'll store the results in a list for final summary
###############################################################################
results_list = []   # each entry: (component, metric, test, stat, p_val, p_shapiro, effect_size)

def process_component(df_comp, comp_label):
    """Pivot for each metric, run stats, store results."""
    out = []
    for metric in metrics:
        # pivot wide
        pivoted = df_comp.pivot(index="Subject", columns="Cond", values=metric)
        # reorder columns => [Nat, Urb], dropna
        pivoted = pivoted[conditions].dropna()
        if pivoted.shape[0] < 2:
            # Not enough data => skip
            out.append((comp_label, metric, "NO_DATA", np.nan, np.nan, np.nan, np.nan))
            continue
        test, stat, p_val, p_shapiro, eff = paired_test(pivoted["Nat"], pivoted["Urb"])
        out.append((comp_label, metric, test, stat, p_val, p_shapiro, eff))
    return out

# EPN
epn_res = process_component(epn_df, "EPN")
# LPP
lpp_res = process_component(lpp_df, "LPP")

results_list.extend(epn_res)
results_list.extend(lpp_res)

###############################################################################
# Bonferroni correction
###############################################################################
# We have 6 tests in total: (EPN, LPP) × (Peak, Mean, Lat)
# Let's gather their p-values
p_vals = [r[4] for r in results_list]  # index=4 is p_val
# Some might be NaN if no data; we skip them
p_vals_clean = [x for x in p_vals if pd.notna(x)]
bonf_alpha = 0.05 / 6

# We'll store the corrected significance in the final summary
# A quick way is to multiply each p_val by 6 (the number of tests)
# (Then compare to 0.05, or just see if new_p < 0.05)
corr_p_vals = []
for i, (comp, metric, test, stat, p_val, p_shapiro, eff) in enumerate(results_list):
    if pd.notna(p_val):
        p_corr = p_val * 6
        # clamp if p_corr>1 => p_corr=1
        if p_corr>1: p_corr=1
    else:
        p_corr = np.nan
    corr_p_vals.append(p_corr)

###############################################################################
# 5) Create boxplots for each metric difference (Nat - Urb), EPN vs. LPP
###############################################################################
# We'll do 3 subplots (peak amplitude, mean amplitude, latency),
# each subplot has two box groups: EPN diff, LPP diff

fig, axes = plt.subplots(1, 3, figsize=(12,4))
fig.suptitle("Differences (Nat - Urb) for EPN & LPP", fontsize=14)

all_metrics = ["Peak","Mean","Lat"]
titles = ["Peak amplitude (µV)", "Mean amplitude (µV)", "Peak latency (ms)"]

for i, metric in enumerate(all_metrics):
    ax = axes[i]

    # EPN difference
    epn_pivot = epn_df.pivot(index="Subject", columns="Cond", values=metric)
    epn_pivot = epn_pivot[conditions].dropna()
    epn_diff  = epn_pivot["Nat"] - epn_pivot["Urb"]

    # LPP difference
    lpp_pivot = lpp_df.pivot(index="Subject", columns="Cond", values=metric)
    lpp_pivot = lpp_pivot[conditions].dropna()
    lpp_diff  = lpp_pivot["Nat"] - lpp_pivot["Urb"]

    # Boxplot
    data_box = [epn_diff.dropna(), lpp_diff.dropna()]
    lb = [f"EPN\n(n={len(data_box[0])})", f"LPP\n(n={len(data_box[1])})"]
    bp = ax.boxplot(data_box, labels=lb, patch_artist=True)

    # Some style for publication
    colors = ["lightblue","lightgreen"]
    for patch, color in zip(bp["boxes"], colors):
        patch.set_facecolor(color)

    ax.set_title(titles[i])
    ax.axhline(0, color="gray", linestyle="--", linewidth=1)
    if i==0:
        ax.set_ylabel("Natural - Urban")

plt.tight_layout(rect=[0, 0, 1, 0.95])  # leave space for suptitle
plt.show()

###############################################################################
# 5) (Figure 2): absolute condition values for EPN & LPP
#    2 rows (EPN, LPP) × 3 columns (Peak, Mean, Lat)
###############################################################################
fig2, axes2 = plt.subplots(nrows=2, ncols=3, figsize=(14,6))
fig2.suptitle("Absolute Condition Values (Natural, Urban) for EPN & LPP", fontsize=14)

for row, (df_comp, comp_label) in enumerate([(epn_df, "EPN"), (lpp_df, "LPP")]):
    for col, metric in enumerate(all_metrics):
        ax = axes2[row, col]
        pivot_data = df_comp.pivot(index="Subject", columns="Cond", values=metric)
        pivot_data = pivot_data[conditions].dropna()
        # We'll do a boxplot with 2 boxes: (Nat, Urb)
        box_data = [pivot_data["Nat"].dropna(), pivot_data["Urb"].dropna()]
        labels = [f"Nat\n(n={len(box_data[0])})", f"Urb\n(n={len(box_data[1])})"]
        bp = ax.boxplot(box_data, labels=labels, patch_artist=True)

        # styling
        colors = ["lightsalmon","lightgray"]
        for patch, color in zip(bp["boxes"], colors):
            patch.set_facecolor(color)

        if metric == "Peak":
            ax.set_title(f"{comp_label} - Peak Amplitude (µV)")
        elif metric == "Mean":
            ax.set_title(f"{comp_label} - Mean Amplitude (µV)")
        else:
            ax.set_title(f"{comp_label} - Peak Latency (ms)")

        # if (row==1) and (col==0):
        #     ax.set_ylabel("Amplitude or Latency")

plt.tight_layout(rect=[0, 0, 1, 0.92])
plt.show()

###############################################################################
# 6) Print final summary
###############################################################################
print("\n==================== Final Summary with Bonferroni Correction ====================")
print("We have 6 total tests: EPN & LPP each with 3 metrics (Peak, Mean, Lat).")
print(f"Bonferroni alpha => 0.05/6 = {0.05/6:.4f}\n")

for (comp, metric, test_name, stat_val, p_val, p_sw, eff), p_corr in zip(results_list, corr_p_vals):
    # If no data
    if test_name=="NO_DATA":
        print(f"[{comp}-{metric}] => Not enough data")
        continue
    # Prepare text
    # Show: test_name, stat, p_val, p_corr, effect size if t-test
    # p_shapiro => normality
    if pd.notna(p_val):
        star = ""
        if p_corr < 0.05:
            star = "*"
        # effect size if test_name = "Paired t-test"
        eff_str = "N/A" if (eff is None or np.isnan(eff)) else f"{eff:.3f}"
        print(f"[{comp}-{metric}] {test_name} => stat={stat_val:.3f}, p={p_val:.4g}, p_corr={p_corr:.4g}{star}, normalDiff={p_sw:.3f}, effSize={eff_str}")
    else:
        print(f"[{comp}-{metric}] => missing p-value (no data?)")

print("\nDone. See the summary above.")
