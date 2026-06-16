#!/usr/bin/env python3
"""
analyse_fault_summary.py

Reads the CSV produced by the MATLAB fault postprocessor and writes:
  1. A human-readable Markdown report
  2. Optional terminal ranking CSVs
  3. Optional plots if matplotlib is installed

Usage:
  python analyse_fault_summary.py Fault1_fault_summary.csv --label Fault1
  python analyse_fault_summary.py Fault2_fault_summary.csv --label Fault2

Expected CSV columns:
  Signal, RawMean, RawFinal, RawMin, RawMax, RawPkPk,
  FaultWindowMean, FaultWindowMin, FaultWindowMax, FaultWindowPkPk,
  HPF_RMS, HPF_MaxAbs, HPF_PkPk,
  D_HPF_MaxAbs, D_HPF_TimeOfMax,
  PeakFreq1_Hz, PeakAmp1, PeakFreq2_Hz, PeakAmp2, PeakFreq3_Hz, PeakAmp3
"""

from __future__ import annotations

import argparse
import math
import re
from pathlib import Path
from typing import Dict, List, Optional, Tuple

import numpy as np
import pandas as pd


PREFault_VDC_DEFAULT = {
    1: 2000.0,
    2: 2000.0,
    3: 1828.0,
    4: 1745.0,
}


def parse_signal_name(signal: str) -> Tuple[Optional[str], Optional[int], Optional[str]]:
    """
    Returns (kind, terminal, pole)
      kind: "Vdc", "Vpole", "I"
      terminal: 1..4
      pole: "+", "-", or None
    """
    s = str(signal).strip()

    m = re.fullmatch(r"V_(\d+)", s)
    if m:
        return "Vdc", int(m.group(1)), None

    m = re.fullmatch(r"V_(\d+)([+-])", s)
    if m:
        return "Vpole", int(m.group(1)), m.group(2)

    m = re.fullmatch(r"I_(\d+)([+-])", s)
    if m:
        return "I", int(m.group(1)), m.group(2)

    return None, None, None


def safe_num(x) -> float:
    try:
        if pd.isna(x):
            return float("nan")
        return float(x)
    except Exception:
        return float("nan")


def row_for(df: pd.DataFrame, signal: str) -> Optional[pd.Series]:
    rows = df[df["Signal"].astype(str) == signal]
    if rows.empty:
        return None
    return rows.iloc[0]


def max_abs_from_min_max(row: pd.Series, min_col: str, max_col: str) -> float:
    mn = safe_num(row.get(min_col, np.nan))
    mx = safe_num(row.get(max_col, np.nan))
    return float(np.nanmax([abs(mn), abs(mx)]))


def fmt(x: float, unit: str = "", sig: int = 4) -> str:
    if x is None or not np.isfinite(x):
        return "n/a"
    if abs(x) >= 1e6 or (abs(x) < 1e-3 and x != 0):
        return f"{x:.{sig}e}{unit}"
    return f"{x:.{sig}g}{unit}"


def terminal_metrics(df: pd.DataFrame) -> pd.DataFrame:
    records = []

    for k in range(1, 5):
        vdc = row_for(df, f"V_{k}")
        ip = row_for(df, f"I_{k}+")
        im = row_for(df, f"I_{k}-")
        vp = row_for(df, f"V_{k}+")
        vm = row_for(df, f"V_{k}-")

        rec = {"Terminal": k}

        if vdc is not None:
            rec["Vdc_final"] = safe_num(vdc["RawFinal"])
            rec["Vdc_min"] = safe_num(vdc["RawMin"])
            rec["Vdc_max"] = safe_num(vdc["RawMax"])
            rec["Vdc_pkpk"] = safe_num(vdc["RawPkPk"])
            pref = PREFault_VDC_DEFAULT.get(k, np.nan)
            rec["Vdc_final_pct_of_prefault"] = 100.0 * rec["Vdc_final"] / pref
            rec["Vdc_min_pct_of_prefault"] = 100.0 * rec["Vdc_min"] / pref
            rec["Vdc_collapse_pct"] = 100.0 * (pref - rec["Vdc_min"]) / pref

        if vp is not None:
            rec["Vplus_final"] = safe_num(vp["RawFinal"])
        if vm is not None:
            rec["Vminus_final"] = safe_num(vm["RawFinal"])

        if ip is not None:
            rec["Iplus_abs_peak"] = max_abs_from_min_max(ip, "RawMin", "RawMax")
            rec["Iplus_HPF_maxabs"] = safe_num(ip["HPF_MaxAbs"])
            rec["Iplus_dHPF_maxabs"] = safe_num(ip["D_HPF_MaxAbs"])
            rec["Iplus_dHPF_tmax"] = safe_num(ip["D_HPF_TimeOfMax"])
            rec["Iplus_f1"] = safe_num(ip["PeakFreq1_Hz"])
            rec["Iplus_f1_amp"] = safe_num(ip["PeakAmp1"])

        if im is not None:
            rec["Iminus_abs_peak"] = max_abs_from_min_max(im, "RawMin", "RawMax")
            rec["Iminus_HPF_maxabs"] = safe_num(im["HPF_MaxAbs"])
            rec["Iminus_dHPF_maxabs"] = safe_num(im["D_HPF_MaxAbs"])
            rec["Iminus_dHPF_tmax"] = safe_num(im["D_HPF_TimeOfMax"])
            rec["Iminus_f1"] = safe_num(im["PeakFreq1_Hz"])
            rec["Iminus_f1_amp"] = safe_num(im["PeakAmp1"])

        # combined pole metrics
        rec["I_abs_peak_max"] = np.nanmax([
            rec.get("Iplus_abs_peak", np.nan),
            rec.get("Iminus_abs_peak", np.nan),
        ])
        rec["HPF_current_maxabs"] = np.nanmax([
            rec.get("Iplus_HPF_maxabs", np.nan),
            rec.get("Iminus_HPF_maxabs", np.nan),
        ])
        rec["dHPF_current_maxabs"] = np.nanmax([
            rec.get("Iplus_dHPF_maxabs", np.nan),
            rec.get("Iminus_dHPF_maxabs", np.nan),
        ])

        # pole symmetry check
        p = rec.get("Iplus_abs_peak", np.nan)
        n = rec.get("Iminus_abs_peak", np.nan)
        if np.isfinite(p) and np.isfinite(n) and max(p, n) > 0:
            rec["Pole_current_asymmetry_pct"] = 100.0 * abs(p - n) / max(p, n)
        else:
            rec["Pole_current_asymmetry_pct"] = np.nan

        records.append(rec)

    return pd.DataFrame(records)


def infer_fault_location(metrics: pd.DataFrame) -> Dict[str, object]:
    out: Dict[str, object] = {}

    for col, name in [
        ("I_abs_peak_max", "raw current peak"),
        ("HPF_current_maxabs", "HPF current"),
        ("dHPF_current_maxabs", "d/dt of HPF current"),
        ("Vdc_collapse_pct", "DC voltage collapse"),
    ]:
        if col in metrics and metrics[col].notna().any():
            idx = metrics[col].idxmax()
            out[name] = {
                "terminal": int(metrics.loc[idx, "Terminal"]),
                "value": float(metrics.loc[idx, col]),
            }

    # Simple rule-based location statement
    d_terminal = out.get("d/dt of HPF current", {}).get("terminal")
    hpf_terminal = out.get("HPF current", {}).get("terminal")
    raw_terminal = out.get("raw current peak", {}).get("terminal")

    votes = [x for x in [d_terminal, hpf_terminal, raw_terminal] if x is not None]
    if votes:
        out["dominant_terminal"] = max(set(votes), key=votes.count)
    else:
        out["dominant_terminal"] = None

    return out


def source_symmetry_text(metrics: pd.DataFrame) -> str:
    try:
        t1 = metrics[metrics["Terminal"] == 1].iloc[0]
        t2 = metrics[metrics["Terminal"] == 2].iloc[0]
    except Exception:
        return "Terminal 1/2 symmetry could not be checked."

    lines = []
    for col, label in [
        ("Vdc_final", "final DC voltage"),
        ("I_abs_peak_max", "raw current peak"),
        ("HPF_current_maxabs", "HPF current"),
        ("dHPF_current_maxabs", "d/dt HPF current"),
    ]:
        a = safe_num(t1.get(col, np.nan))
        b = safe_num(t2.get(col, np.nan))

        if np.isfinite(a) and np.isfinite(b):
            denom = max(abs(a), abs(b), 1e-12)
            diff_pct = 100.0 * abs(a - b) / denom
            lines.append(f"- {label}: T1={fmt(a)}, T2={fmt(b)}, difference={fmt(diff_pct, '%')}")

    return "\n".join(lines) if lines else "Terminal 1/2 symmetry could not be checked."


def frequency_summary(df: pd.DataFrame) -> pd.DataFrame:
    records = []

    for _, row in df.iterrows():
        kind, terminal, pole = parse_signal_name(str(row["Signal"]))
        if kind != "I":
            continue

        records.append({
            "Signal": row["Signal"],
            "Terminal": terminal,
            "Pole": pole,
            "PeakFreq1_Hz": safe_num(row.get("PeakFreq1_Hz", np.nan)),
            "PeakAmp1": safe_num(row.get("PeakAmp1", np.nan)),
            "PeakFreq2_Hz": safe_num(row.get("PeakFreq2_Hz", np.nan)),
            "PeakAmp2": safe_num(row.get("PeakAmp2", np.nan)),
            "PeakFreq3_Hz": safe_num(row.get("PeakFreq3_Hz", np.nan)),
            "PeakAmp3": safe_num(row.get("PeakAmp3", np.nan)),
            "HPF_MaxAbs": safe_num(row.get("HPF_MaxAbs", np.nan)),
            "D_HPF_MaxAbs": safe_num(row.get("D_HPF_MaxAbs", np.nan)),
        })

    return pd.DataFrame(records)


def make_markdown_report(
    df: pd.DataFrame,
    metrics: pd.DataFrame,
    freq: pd.DataFrame,
    label: str,
) -> str:
    inference = infer_fault_location(metrics)
    dominant = inference.get("dominant_terminal")

    lines: List[str] = []
    lines.append(f"# Fault summary report: {label}\n")

    lines.append("## Automatic interpretation\n")

    if dominant is not None:
        lines.append(
            f"The dominant fault signature is at **Terminal {dominant}**, "
            "based mainly on the largest high-pass-filtered current derivative and current transient."
        )
    else:
        lines.append("The script could not identify a dominant terminal from the available columns.")

    lines.append("")

    for key, item in inference.items():
        if not isinstance(item, dict):
            continue
        terminal = item["terminal"]
        value = item["value"]
        lines.append(f"- Largest {key}: Terminal {terminal}, value = {fmt(value)}")

    lines.append("\n## Terminal DC-voltage and current ranking\n")

    view_cols = [
        "Terminal",
        "Vdc_final",
        "Vdc_min",
        "Vdc_collapse_pct",
        "I_abs_peak_max",
        "HPF_current_maxabs",
        "dHPF_current_maxabs",
        "Pole_current_asymmetry_pct",
    ]

    existing = [c for c in view_cols if c in metrics.columns]
    lines.append(metrics[existing].to_markdown(index=False, floatfmt=".6g"))

    lines.append("\n## Source-side symmetry check: Terminal 1 vs Terminal 2\n")
    lines.append(source_symmetry_text(metrics))

    lines.append("\n## Pole symmetry check\n")
    for _, r in metrics.iterrows():
        k = int(r["Terminal"])
        asym = safe_num(r.get("Pole_current_asymmetry_pct", np.nan))
        if np.isfinite(asym):
            if asym < 1:
                verdict = "excellent"
            elif asym < 5:
                verdict = "acceptable"
            else:
                verdict = "large asymmetry; check sensors/pole paths"
            lines.append(f"- Terminal {k}: pole-current asymmetry = {fmt(asym, '%')} → {verdict}")

    lines.append("\n## Frequency content of current signals\n")
    if not freq.empty:
        freq_cols = [
            "Signal",
            "HPF_MaxAbs",
            "D_HPF_MaxAbs",
            "PeakFreq1_Hz",
            "PeakAmp1",
            "PeakFreq2_Hz",
            "PeakAmp2",
            "PeakFreq3_Hz",
            "PeakAmp3",
        ]
        lines.append(freq[freq_cols].to_markdown(index=False, floatfmt=".6g"))
    else:
        lines.append("No current frequency data found.")

    lines.append("\n## Report wording you can reuse\n")
    if dominant is not None:
        lines.append(
            f"For {label}, the strongest transient response occurs at Terminal {dominant}. "
            f"The largest high-frequency current and largest derivative of the high-pass-filtered current "
            f"are both associated with this terminal, indicating that it is electrically closest to the faulted section. "
            f"Terminals with lower HPF and derivative magnitudes are affected through the mesh but are not the dominant local discharge path."
        )

    lines.append(
        "\nThe raw voltage minima describe which parts of the DC grid collapse after the fault, "
        "while the HPF current and derivative metrics identify the sharp capacitive-discharge signature. "
        "For a symmetric pole-to-pole fault, positive- and negative-pole current magnitudes should be similar with opposite sign, "
        "so low pole-current asymmetry supports a correctly wired symmetric-monopole model."
    )

    return "\n".join(lines) + "\n"


def save_plots(metrics: pd.DataFrame, out_dir: Path, label: str) -> None:
    try:
        import matplotlib.pyplot as plt
    except Exception:
        print("matplotlib not installed; skipping plots.")
        return

    out_dir.mkdir(parents=True, exist_ok=True)

    plots = [
        ("I_abs_peak_max", "Raw current absolute peak [A]", "raw_current_peak.png"),
        ("HPF_current_maxabs", "HPF current max abs [A]", "hpf_current.png"),
        ("dHPF_current_maxabs", "d/dt HPF current max abs [A/s]", "dhpf_current.png"),
        ("Vdc_collapse_pct", "DC voltage collapse [% of prefault]", "vdc_collapse.png"),
    ]

    for col, ylabel, fname in plots:
        if col not in metrics.columns:
            continue

        plt.figure()
        plt.bar(metrics["Terminal"].astype(str), metrics[col])
        plt.xlabel("Terminal")
        plt.ylabel(ylabel)
        plt.title(f"{label}: {ylabel}")
        plt.grid(axis="y", alpha=0.3)
        plt.tight_layout()
        plt.savefig(out_dir / fname, dpi=200)
        plt.close()


def main() -> None:
    csv_input = input("Enter fault summary CSV filename/path: ").strip().strip('"').strip("'")

    if not csv_input:
        raise SystemExit("No CSV file entered.")

    csv_path = Path(csv_input)

    if not csv_path.exists():
        raise SystemExit(f"File not found: {csv_path}")

    label_input = input("Enter fault label, e.g. Fault1 or Fault2, or press Enter to use filename: ").strip()
    label = label_input if label_input else csv_path.stem

    plots_input = input("Save simple ranking plots? y/n [y]: ").strip().lower()
    save_plot_flag = plots_input in ("", "y", "yes")

    out_path = csv_path.with_name(f"{csv_path.stem}_analysis_report.md")

    df = pd.read_csv(csv_path)
    metrics = terminal_metrics(df)
    freq = frequency_summary(df)

    report = make_markdown_report(df, metrics, freq, label)

    out_path.write_text(report, encoding="utf-8")

    metrics_path = csv_path.with_name(f"{csv_path.stem}_terminal_metrics.csv")
    freq_path = csv_path.with_name(f"{csv_path.stem}_frequency_metrics.csv")

    metrics.to_csv(metrics_path, index=False)
    freq.to_csv(freq_path, index=False)

    if save_plot_flag:
        save_plots(metrics, csv_path.with_name(f"{csv_path.stem}_plots"), label)

    print("\n" + report)
    print(f"\nWrote report: {out_path}")
    print(f"Wrote terminal metrics: {metrics_path}")
    print(f"Wrote frequency metrics: {freq_path}")

    if save_plot_flag:
        print(f"Wrote plots folder: {csv_path.with_name(f'{csv_path.stem}_plots')}")


if __name__ == "__main__":
    main()