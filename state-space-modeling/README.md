# State-Space Modeling for Asset Allocation

A validation study evaluating whether **state-space model (SSM) filtering** of financial returns improves portfolio allocation performance compared to using raw, unfiltered data.

## Overview

This project compares portfolio allocation outcomes when using raw (unfiltered) returns versus returns filtered through two state-space models:

1. **Gaussian AR(1) SSM** - Standard Kalman filtering assuming normally distributed innovations
2. **Student-t AR(1) SSM** - Particle filtering with heavy-tailed innovations, robust to outliers

The filtered returns are fed into 4 portfolio optimization methods, and out-of-sample performance is evaluated via rolling-window backtesting. The study tests whether the signal-noise decomposition provided by SSM filtering translates to improved allocation decisions.

---

## Research Question

**Does preprocessing financial returns through state-space filtering improve portfolio allocation performance?**

This study investigates:
1. Whether SSM filtering improves allocation returns vs. raw data
2. How Gaussian vs. Student-t filtering compare under different market conditions
3. Which allocation methods benefit most from filtering
4. The filtering-turnover trade-off

---

## Methodology

### State-Space Model Formulation

**AR(1) State-Space Structure:**
```
State equation:       x_t = φ × x_{t-1} + η_t
Observation equation: y_t = x_t + ε_t
```

Where `x_t` is the latent "true" return signal and `y_t` is the observed noisy return.

### Filtering Approaches

| Approach | Method | Implementation | Innovation Distribution |
|----------|--------|----------------|------------------------|
| **Raw** | None | - | Baseline (no filtering) |
| **Gaussian** | Kalman Filter | R/KFAS | Normal |
| **Student-t** | Particle Filter | R/pomp | Heavy-tailed (robust) |

### Allocation Methods Evaluated

| Method | Description | Objective |
|--------|-------------|-----------|
| **MV** | Mean-Variance | Minimize variance for target return |
| **CVaR** | Conditional Value-at-Risk | Minimize tail risk (95% CVaR) |
| **Omega** | Omega Ratio | Maximize gain-loss ratio |
| **MVEU** | Mean-Variance Ellipsoid Uncertainty | Robust to estimation error |

### Validation Protocol

- **Rolling windows**: 252-day estimation, 63-day testing, 63-day step
- **Benchmark**: Equal-weight (50/50) portfolio
- **Metrics**: Sharpe Ratio, Maximum Drawdown, Cumulative Wealth, Turnover
- **Total strategies**: 15 (5 methods × 3 scenarios)

---

## Key Findings

### Allocation Performance by Scenario

| Model | Scenario | Avg Return | Avg Std | Avg Sharpe |
|-------|----------|------------|---------|------------|
| **Omega** | Student-t | **0.000345** | 0.000511 | 0.70 |
| EqualWeight | Student-t | 0.000210 | 0.000255 | 0.84 |
| EqualWeight | Unfiltered | 0.000171 | 0.003812 | 0.09 |
| MVEU | Student-t | 0.000124 | 0.000088 | 3.82 |
| CVaR | Student-t | 0.000123 | 0.000085 | 10.11 |
| MV | Student-t | 0.000122 | 0.000084 | **34.69** |

*Top strategies from 15 evaluated (5 methods × 3 scenarios)*

### Cross-Scenario Comparison

| Metric | Unfiltered | Gaussian | Student-t |
|--------|------------|----------|-----------|
| **Avg Return** | 0.000096 | 0.000088 | **0.000185** |
| **Avg Sharpe** | 24.64 | 57.74 | 12.35 |
| **Strategies > Benchmark** | 4/4 | 4/4 | 4/4 |

*Averaged across 4 optimization methods, excluding EqualWeight*

**Key Result**: Student-t filtering yields +93% higher average return vs. unfiltered data.

### Best Combinations

| Investor Profile | Recommended Model | Filtering Method |
|-----------------|------------------|------------------|
| **Risk-averse** | CVaR | Student-t SSM |
| **Return-focused** | Omega | Student-t SSM |
| **Balanced** | MV | Gaussian SSM |
| **Robust/Institutional** | MVEU | Raw or minimal |

---

## View the Results

### Executive Summary (Recommended Starting Point)
→ [docs/EXECUTIVE_SUMMARY.md](docs/EXECUTIVE_SUMMARY.md)
- Performance comparison tables
- Model-specific insights
- Strategic recommendations
- Limitations and future work

### Analysis Reports
- R markdown and Julia notebooks in `outputs/reports/`
- Clone repository to view full analysis locally

---

## Repository Structure

```
state-space-modeling/
├── README.md                    # This file
├── docs/
│   └── EXECUTIVE_SUMMARY.md     # High-level findings
├── src/
│   └── README.md                # API documentation
├── outputs/
│   ├── reports/                 # Analysis reports
│   ├── figures/                 # Visualizations
│   └── data/                    # Summary statistics
├── data/
│   ├── raw/                     # TSX + T-bill data
│   ├── filtered/                # SSM filtered outputs
│   └── allocation/              # Allocation results
└── tests/                       # Test suite
```

---

## Technical Stack

### Languages & Tools

| Language | Purpose |
|----------|---------|
| **R** | Data import, SSM estimation (KFAS, pomp) |
| **Julia** | Portfolio optimization (JuMP, HiGHS) |

### Key Packages

| Package | Language | Purpose |
|---------|----------|---------|
| KFAS | R | Kalman filtering for Gaussian SSM |
| pomp | R | Particle filtering for Student-t SSM |
| JuMP | Julia | Mathematical optimization |
| tidyquant | R | Financial data download |

### Integration Pattern
File-based (CSV) data exchange between R and Julia components.

---

## Asset Universe

- **TSX Composite Index** (^GSPTSE) - Canadian equity market
- **Canadian 3-Month T-Bills** - Risk-free asset proxy
- **Period**: 2015-01-01 to present

---

## Key References

### State-Space Modeling
- Durbin & Koopman (2012): *Time Series Analysis by State Space Methods*
- Commandeur & Koopman (2007): *An Introduction to State Space Time Series Analysis*

### Portfolio Optimization
- Markowitz (1952): "Portfolio Selection"
- Rockafellar & Uryasev (2000): "Optimization of Conditional Value-at-Risk"

---

## Project Status

**Status**: ✅ Complete (January 2025)

### Completed Phases
1. **Data Import** - TSX index and T-bill rates downloaded and processed
2. **SSM Estimation** - Gaussian (Kalman) and Student-t (particle) filters fitted
3. **Portfolio Allocation** - 4 methods × 3 scenarios = 12 strategies + benchmark
4. **Backtest Validation** - Rolling window out-of-sample evaluation

---

## Limitations & Future Work

### Current Limitations
- **Two-asset universe**: Production systems handle 100-1000+ assets
- **~10 years data**: Institutional studies use 20-30+ years
- **No transaction costs**: Net returns would differ
- **Rolling window only**: No true holdout set

### Future Extensions
1. Scale to 50-100+ assets with sector constraints
2. Transaction cost integration
3. Regime-switching SSM models
4. True out-of-sample holdout validation

---

**Last Updated**: January 2025
