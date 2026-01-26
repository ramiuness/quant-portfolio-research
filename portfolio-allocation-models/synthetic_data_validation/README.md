# Portfolio Optimization Models: Synthetic Data Validation

A comprehensive validation study of portfolio optimization models using synthetic data, comparing classical and robust approaches across multiple analytical dimensions.

## Overview

This project validates **5 portfolio optimization models** on controlled synthetic data to understand their characteristics, performance trade-offs, and strategic implications before applying them to real market data.

### Models Analyzed (Phase A)

1. **MV** - Mean-Variance (Classical)
2. **CVaR** - Conditional Value-at-Risk
3. **Omega** - Omega Ratio
4. **MVBU** - Mean-Variance Box-Uncertainty (Robust)
5. **MVEU** - Mean-Variance Ellipsoid-Uncertainty (Robust)

**Note**: Phase B will add distribution-based robust models (RCVaR, ROmega) after GMM fitting.

---

## 📊 View the Results

### Executive Summary (Recommended Starting Point)
→ [docs/EXECUTIVE_SUMMARY.md](docs/EXECUTIVE_SUMMARY.md)
- High-level findings and strategic recommendations
- Key insights from all 4 analytical themes
- Model selection guidelines
- Ideal for stakeholders and quick overview

### Jupyter Notebook (Full Technical Analysis)
→ [outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb](outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb)
- Complete reproducible analysis with source code
- All visualizations and performance metrics
- Four analytical themes: Performance, Diversification, Classical vs Robust, Risk-Return Trade-offs
- **Note**: Clone the repository to view plots locally, or see visualizations below

---

## Key Findings at a Glance

### 🎯 Key Milestone: All Models Beat Benchmark
With quintile-based target selection, **all 5 models achieve positive Information Ratio**.

| Model | Sharpe (Before) | Sharpe (After) | Improvement |
|-------|-----------------|----------------|-------------|
| CVaR  | 1.16            | 1.32           | +14%        |
| MV    | 1.03            | 1.24           | +20%        |
| MVBU  | 1.03            | 1.24           | +20%        |
| Omega | 1.31            | 1.31           | (tau=0)     |
| MVEU  | 1.06            | 1.08           | +2%         |

### 🏆 Performance Winners: **CVaR and Omega**
- CVaR: Sharpe **1.32**, IR 0.80
- Omega: Sharpe **1.31**, IR 0.86 (highest)

### 📈 Diversification Champion: **MVEU**
- Capacity: **28.33 effective bets** (9x more than classical models)
- Invests in all 30 stocks
- Now beats benchmark with quintile targets + alpha search

### 🎯 Model Selection

| Investment Goal | Recommended Model | Key Metric |
|----------------|------------------|-----------|
| **Best Risk-Adjusted** | CVaR or Omega | Sharpe: 1.32 / 1.31 |
| **Scalability (High AUM)** | MVEU | Capacity: 28.33 |
| **Tail-Risk Protection** | CVaR | Lowest volatility |

---

## Project Structure

```
synthetic_data_validation/
├── README.md                    # This file - project overview
├── GOAL.md                      # Project objectives and milestones
│
├── src/                         # Source code
│   ├── adaptive_optimization.jl # Adaptive target/threshold system
│   ├── compute_metrics.jl       # Performance metrics computation
│   ├── visualize_themes.jl      # Visualization functions
│   ├── denoise_covariance.jl    # RMT covariance denoising
│   └── robustOptimization.jl    # Core optimization models
│
├── tests/                       # Test suite
│   ├── test_adaptive_targets.jl
│   ├── test_annualization_fix.jl
│   ├── test_denoise_covariance.jl # Covariance denoising tests
│   └── test_task*.jl           # Task-specific tests
│
├── outputs/                     # Analysis results
│   ├── reports/                # Final reports
│   │   ├── Phase1_Synthetic_Validation_Complete.ipynb
│   │   ├── Phase1_Synthetic_Validation_Complete.html
│   │   └── REPORT_README.md   # Report generation guide
│   ├── figures/               # Generated visualizations
│   │   ├── theme*_*.png      # Thematic analysis plots
│   │   └── weight_heatmap.png
│   └── data/                 # Computed metrics
│       ├── metrics_5models.csv
│       └── validation_summary_5models.csv
│
└── docs/                      # Documentation
    ├── EXECUTIVE_SUMMARY.md  # High-level findings
    ├── NOTEBOOK_GUIDE.md     # Notebook usage guide
    ├── PROGRESS_SUMMARY.md   # Development timeline
    └── *.md                  # Technical documentation
```

---

## Analytical Framework

The analysis is organized into **4 thematic questions**:

### Theme 1: Performance Metrics
**Question**: How do models perform on synthetic data?
- Sharpe, Information, and Sortino ratios
- Cumulative PnL analysis
- **Winner**: CVaR (Sharpe: 1.32), Omega close second (1.31)

### Theme 2: Diversification & Capacity
**Question**: How concentrated are portfolios and what's the investment capacity?
- Effective number of bets (capacity)
- Number of invested stocks
- **Range**: 3.23 to 28.33 effective bets (9x difference!)

### Theme 3: Classical vs Robust Approaches
**Question**: How does robustness change portfolio characteristics?
- Mean-Variance family comparison (MV, MVBU, MVEU)
- MV ≈ MVBU on synthetic data
- **Insight**: MVEU provides 9x capacity while still beating benchmark (with quintile targets)

### Theme 4: Risk-Return Trade-offs
**Question**: What relationships exist between risk, return, and diversification?
- Efficient frontier patterns
- Capacity vs. performance analysis
- **Finding**: All models beat benchmark with proper target tuning

---

## Methodology

### Data Generation
- **Distribution**: Multivariate lognormal
- **Parameters**: Estimated from real DJIA historical data
- **Size**: 4,223 observations × 30 assets
- **Benefit**: Controlled environment with known properties

### Validation
- ✅ All models pass technical constraints
- ✅ Quintile-based target selection (Q80 → Q60 → Q40 → Q20)
- ✅ MVEU alpha search for optimal uncertainty set size
- ✅ Solver convergence verification
- ✅ Weight sum and non-negativity checks

### Target Selection Strategy
- **MV, CVaR, MVBU, MVEU**: Search targets at quintiles of mean asset returns, use highest feasible
- **Omega**: Fixed tau=0 (economically meaningful threshold)
- **MVEU**: Additional alpha search [0.50, 0.70, 0.85, 0.95, 0.99] for best Sharpe

### Metrics
- **Return**: Mean return, cumulative PnL
- **Risk**: Volatility, CVaR, downside deviation
- **Risk-Adjusted**: Sharpe, Sortino, Information Ratio, Omega Ratio
- **Portfolio Characteristics**: Diversification, capacity (1/HHI), max weight
- **Baseline**: Equally-Weighted (EW) portfolio for benchmark comparisons
- **Reporting**: Annualized format (252 trading days)

---

## Quick Start

### Prerequisites
- Julia 1.6+
- Required packages: DataFrames, CSV, Statistics, LinearAlgebra, Distributions, Plots, PrettyTables, JuMP, Ipopt

### Running the Analysis

```julia
# 1. Navigate to project directory
cd("synthetic_data_validation/")

# 2. Load packages and functions
include("src/compute_metrics.jl")
include("src/adaptive_optimization.jl")
include("src/visualize_themes.jl")

# 3. Open the Jupyter notebook
# jupyter notebook outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb

# 4. Run all cells to reproduce the analysis
```

### Generating HTML Report

```bash
# Clean HTML with code hidden (recommended for sharing)
jupyter nbconvert --to html --no-input outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb

# Alternative: HTML with code visible
jupyter nbconvert --to html outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb
```

See [outputs/reports/REPORT_README.md](outputs/reports/REPORT_README.md) for detailed instructions.

---

## Technical Innovations

### 1. Adaptive Optimization System
- **Problem**: Fixed targets may be infeasible, causing validation failures
- **Solution**: Automatically adjust targets/thresholds when constraints cannot be met
- **Benefit**: Robust, publication-ready results with proper validation
- **Documentation**: [docs/ADAPTIVE_TARGETS_README.md](docs/ADAPTIVE_TARGETS_README.md)

### 2. Covariance Denoising (RMT)
- **Method**: Marcenko-Pastur random matrix theory (López de Prado)
- **Purpose**: Separate signal from noise in sample covariance eigenvalues
- **Implementation**: Constant residual, targeted shrinkage, detoning methods
- **Benefit**: Improved portfolio stability and condition number

---

## Next Steps (Phase B)

1. **Fit GMM** to synthetic data using BIC selection
2. **Implement distribution-based models**: RCVaR and ROmega
3. **Theme 5 Analysis**: Compare distribution-based vs. sample-based approaches
4. **Update visualizations** with all 7 models
5. **Comprehensive final report** integrating all findings

---

## Documentation

- **[EXECUTIVE_SUMMARY.md](docs/EXECUTIVE_SUMMARY.md)** - High-level findings for stakeholders
- **[NOTEBOOK_GUIDE.md](docs/NOTEBOOK_GUIDE.md)** - How to use the Jupyter notebooks
- **[ADAPTIVE_TARGETS_README.md](docs/ADAPTIVE_TARGETS_README.md)** - Adaptive optimization system
- **[IMPROVEMENTS_SUMMARY.md](docs/IMPROVEMENTS_SUMMARY.md)** - Technical improvements log
- **[PROGRESS_SUMMARY.md](docs/PROGRESS_SUMMARY.md)** - Development timeline

---

## Citation

```
Portfolio Optimization Models: Synthetic Data Validation
Validation framework for classical and robust portfolio optimization approaches
2026
```
