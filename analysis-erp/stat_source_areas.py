# -*- coding: utf-8 -*-
"""
dipole_analysis.py

A script to analyze and visualize dipole information from an .xlsx file. 
We prioritize descriptive summaries (counts, groupings) and simple plots 
(e.g., bar charts) to illustrate the distribution of dipoles across 
subjects, conditions, and anatomical areas.

Author: YourName
Date: 2025-01-06
"""

import os
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

###############################################################################
# 1) Configuration
###############################################################################
xlsx_file = r"C:\Users\joaop\pessoal\educacao\projetoTese\dipoles.xlsx"
output_path = r"C:\Users\joaop\pessoal\educacao\projetoTese"  # or any desired folder

###############################################################################
# 2) Load data
###############################################################################
df = pd.read_excel(xlsx_file)

# Check columns we expect
needed_cols = ["Subject","Condition","ERP","Latency","ba","anat","activity interval","dipole"]
if not set(needed_cols).issubset(df.columns):
    raise ValueError(f"Input XLSX must contain columns {needed_cols}")

###############################################################################
# 3) Basic cleaning and info
###############################################################################
df.dropna(subset=["Subject","Condition","anat","dipole"], inplace=True)
df["Subject"] = df["Subject"].astype(str)
df["Condition"] = df["Condition"].astype(str)
df["anat"] = df["anat"].astype(str)
df["ERP"] = df["ERP"].astype(str)

print("Data head:")
print(df.head(), "\n")

print("Unique subjects:", df["Subject"].unique())
print("Unique conditions:", df["Condition"].unique())
print("Total dipoles in dataset:", len(df))

###############################################################################
# 4) Summaries
###############################################################################
# a) Count how many dipoles per subject & condition
dipole_counts = df.groupby(["Subject","Condition"])["dipole"].count().reset_index()
dipole_counts.rename(columns={"dipole":"DipoleCount"}, inplace=True)

# b) Most frequent 'anat' for each condition
anat_counts = (
    df.groupby(["anat","Condition"])["dipole"]
    .count()
    .reset_index()
    .rename(columns={"dipole":"Count"})
    .sort_values("Count", ascending=False)
)

# c) Possibly also look at distribution of BA or "ba" column
ba_counts = df.groupby("ba")["dipole"].count().reset_index().sort_values("dipole", ascending=False)

###############################################################################
# 5) Print some key info
###############################################################################
print("\n=== DIPOLE COUNTS BY SUBJECT & CONDITION ===")
print(dipole_counts)

print("\n=== MOST FREQUENT ANATOMICAL AREAS ===")
print(anat_counts.head(15))

print("\n=== BA distribution (top 10) ===")
print(ba_counts.head(10))

###############################################################################
# 6) Simple Plotting
###############################################################################
# a) Bar plot: number of dipoles per subject & condition
plt.figure(figsize=(8,5))
sns.barplot(data=dipole_counts, x="Subject", y="DipoleCount", hue="Condition", palette="Set2")
plt.xticks(rotation=45)
plt.title("Dipole Count per Subject & Condition")
plt.ylabel("Count of Dipoles")
plt.tight_layout()
plt.savefig(os.path.join(output_path,"dipoles_per_subject_condition.png"), dpi=150)
plt.show()

# b) Bar plot: top areas for each condition
# We'll select top 10 from each condition for clarity
top10_nat = anat_counts.loc[anat_counts["Condition"]=="Nat"].head(10)
top10_urb = anat_counts.loc[anat_counts["Condition"]=="Urb"].head(10)

plt.figure(figsize=(10,4))
plt.subplot(1,2,1)
sns.barplot(data=top10_nat, x="Count", y="anat", color="lightblue")
plt.title("Nature")
plt.subplot(1,2,2)
sns.barplot(data=top10_urb, x="Count", y="anat", color="salmon")
plt.title("Urban")
plt.tight_layout()
plt.savefig(os.path.join(output_path,"top10_anat_nat_urb.png"), dpi=150)
plt.show()

###############################################################################
# 5) Create an expanded stacked bar plot: (Anat + Condition) on x-axis
#    colored by BA, with height as sum of dipoles
###############################################################################
# a) We find top anatomical areas overall
sum_anat_overall = sum_anat_overall.head(TOP_ANAT_COUNT)
top_anat_list = sum_anat_overall["anat"].tolist()

# b) Filter original df to only these top areas
df_top = df[df["anat"].isin(top_anat_list)].copy()

# c) Create a new column that combines (anat + Condition) => "anat_cond"
df_top["anat_cond"] = df_top["anat"] + " (" + df_top["Condition"] + ")"

# d) Group by (anat_cond, ba) => count dipoles
grouped = df_top.groupby(["anat_cond","ba"])["dipole"].count().reset_index()
grouped.rename(columns={"dipole":"Count"}, inplace=True)

# e) Pivot so that columns=BA, index=anat_cond
pivoted = grouped.pivot(index="anat_cond", columns="ba", values="Count").fillna(0)

# f) Sort index by sum
pivoted_sum = pivoted.sum(axis=1)
pivoted = pivoted.loc[pivoted_sum.sort_values(ascending=False).index]

# g) Plot as stacked bar
plt.figure(figsize=(10,5))
pivoted.plot(kind="bar", stacked=True, ax=plt.gca(), colormap="tab20")
plt.title(f"Stacked Bar: Top {TOP_ANAT_COUNT} Anatomical Areas (Nat vs Urb) by BA")
plt.ylabel("Count of Dipoles")
plt.xticks(rotation=45, ha="right")
plt.legend(title="BA", bbox_to_anchor=(1.02,1), loc="upper left", borderaxespad=0)
plt.tight_layout()
plt.savefig(os.path.join(output_path,"stacked_anat_cond_ba.png"), dpi=150)
plt.show()

###############################################################################
# 6) Optional small test (example: difference in Latency between conditions)
###############################################################################
df_lat_pivot = df.pivot_table(index="Subject", columns="Condition", values="Latency", aggfunc="mean")
df_lat_pivot.dropna(inplace=True)
if df_lat_pivot.shape[1] == 2:
    from scipy.stats import ttest_rel
    diff = df_lat_pivot["Nat"] - df_lat_pivot["Urb"]
    t_stat, p_val = ttest_rel(df_lat_pivot["Nat"], df_lat_pivot["Urb"])
    print("\nOptional Paired T-test on Latency (Nat vs Urb):")
    print(f" t={t_stat:.3f}, p={p_val:.4g}, (n={len(diff)})")
else:
    print("\nNot enough columns to do a Nat vs Urb latency test.")

print("\nAnalysis complete. Outputs saved to:", output_path)
print("Done.")

###############################################################################
# 8) Print done
###############################################################################
print("\nAnalysis complete. Outputs saved to:", output_path)
print("Done.")
