# Integrated Learning for Portfolio Optimization

A validation study comparing **Predict-then-Optimize (PO)** and **Smart Predict-then-Optimize (SPO)** approaches for Mean-Variance portfolio construction with learnable risk aversion.

## Overview

This project presents a comprehensive validation study comparing two paradigms for integrating machine learning with portfolio optimization:

1. **Predict-then-Optimize (PO)**: The traditional two-stage approach where a model first predicts expected returns, then a separate optimization step constructs the portfolio treating predictions as given.

2. **Smart Predict-then-Optimize (SPO)**, also known as **Decision-Focused Learning**: An end-to-end approach where the prediction model is trained with direct awareness of the downstream optimization objective, allowing gradients to flow through the portfolio construction step.

This work extends the theoretical framework established in *"Distributionally Robust End-to-End Portfolio Construction"* (Costa & Iyengar, Quantitative Finance, 2023), applying decision-focused learning to Mean-Variance optimization with learnable risk aversion.

The study evaluates whether embedding optimization objectives directly into the learning process—allowing the model to jointly learn prediction parameters and risk preferences—yields superior portfolio outcomes compared to the traditional sequential paradigm.

---

## Research Questions

This study investigates several interconnected questions at the intersection of machine learning and portfolio theory:

1. **Decision-Focused vs. Predict-then-Optimize**: Does training the prediction model with awareness of the downstream optimization objective lead to better portfolio decisions than the traditional two-stage approach?

2. **Learnable vs. Fixed Risk Preferences**: Can the model discover an optimal risk aversion coefficient (κ) through gradient-based learning, and how does this data-driven parameterization compare to conventional fixed values?

3. **Synthetic vs. Real Market Performance**: How does the relative advantage of SPO over PO transfer from a controlled synthetic environment to real market data where model assumptions may be violated?

4. **Portfolio Concentration Trade-offs**: What is the impact of diversification constraints on risk-adjusted returns? How do constrained portfolios compare to unconstrained solutions in terms of Sharpe ratio, drawdown protection, and effective number of holdings?

5. **Risk Aversion Sensitivity**: How robust are portfolio outcomes to the choice of κ, and does the learned value fall within a stable performance region?

---

## Methodology

### Factor-Based Return Prediction

Expected asset returns are modeled as linear functions of systematic risk factors, following the Arbitrage Pricing Theory tradition. The feature set comprises **8 Fama-French factors**:

| Factor | Description |
|--------|-------------|
| Market | Excess return of the market portfolio |
| SMB | Small Minus Big (size premium) |
| HML | High Minus Low (value premium) |
| RMW | Robust Minus Weak (profitability) |
| CMA | Conservative Minus Aggressive (investment) |
| MOM | Momentum (12-1 month return) |
| ST_Rev | Short-term reversal |
| LT_Rev | Long-term reversal |

The prediction model learns factor exposures (β) that map observable factors to expected returns. This factor-based approach grounds the study in established asset pricing theory while providing economically interpretable features.

### Optimization Paradigms

**Predict-then-Optimize (PO)**: The prediction model minimizes forecasting error (MSE) without regard to how predictions will be used. The optimizer then treats these predictions as ground truth.

**Smart Predict-then-Optimize (SPO)**: The prediction model minimizes realized portfolio loss, computed by passing predictions through the optimization layer and evaluating against actual returns. This decision-focused objective aligns learning with the ultimate investment goal.

### Differentiable Optimization Layer

The Mean-Variance optimization problem is embedded as a differentiable layer using cvxpylayers:

```
maximize:  μᵀw - κ wᵀΣw
subject to: w ≥ 0, 1ᵀw = 1, w ≤ max_weight (optional)
```

Where:
- μ: Predicted expected returns (from factor model)
- Σ: Covariance matrix (updated via rolling window)
- κ: Risk aversion coefficient (fixed in PO, learnable in SPO)
- w: Portfolio weights

This formulation enables gradient-based learning of the risk aversion coefficient κ, treating it as a differentiable parameter rather than a fixed hyperparameter.

### Validation Environments

The methodology is validated across two complementary data settings:

**Calibrated Synthetic Data**: 20 assets driven by 8 factors with embedded volatility regime transitions (low → normal → high). Statistical properties are calibrated to historical market data. This controlled environment provides a ground-truth baseline where model assumptions hold by construction.

**Real Market Data**: 20 US equities spanning major sectors (Technology, Financials, Energy, Consumer, Healthcare, etc.) from 2000–2025. This tests robustness under real-world conditions including distributional shifts, factor instability, and market microstructure effects.

### Evaluation Protocol

All models undergo **rolling-window out-of-sample backtesting** (4 windows) with periodic covariance re-estimation. This simulates realistic portfolio management where:
- Models are trained on historical data
- Performance is measured on subsequent unseen periods
- Parameters are updated as new information arrives

Metrics evaluated: Sharpe Ratio, Sortino Ratio, Maximum Drawdown, Turnover, and Effective Number of Holdings.

---

## Models Evaluated

| Model | Type | Risk Aversion | Constraints |
|-------|------|---------------|-------------|
| **EW** | Benchmark | N/A | Equal weight 1/n |
| **PO-MV** | Predict-then-Optimize | Fixed κ=1.0 | Unconstrained |
| **PO-MV-Constrained** | Predict-then-Optimize | Fixed κ=1.0 | max_weight=20% |
| **E2E-MV-Learned** | Smart Predict-then-Optimize | Learnable κ | Unconstrained |
| **E2E-MV-Constrained** | Smart Predict-then-Optimize | Learnable κ | max_weight=20% |

---

## View the Results

### Executive Summary (Recommended Starting Point)
→ [docs/EXECUTIVE_SUMMARY.md](docs/EXECUTIVE_SUMMARY.md)
- High-level findings and strategic recommendations
- Performance comparison tables
- Visual results with figures
- Ideal for stakeholders and quick overview

### Validation Reports
- [Synthetic Data Validation](outputs/reports/mv_validation_synthetic_report.ipynb) - Controlled environment testing
- [Real Data Validation](outputs/reports/mv_validation_real_report.ipynb) - Market data evaluation

### API Documentation
→ [src/README.md](src/README.md)
- e2edro library reference
- Usage examples
- Original source attribution

---

## Key Findings

### Cross-Environment Comparison

| Metric | Synthetic Data | Real Data |
|--------|---------------|-----------|
| Best Sharpe | PO-MV-Constrained (0.85) | EW Benchmark (0.14) |
| Learned κ | 0.11 (less risk-averse) | 0.11 (consistent) |
| SPO vs PO | Comparable performance | No clear advantage |
| Constraint benefit | +80% Sortino improvement | -8% drawdown reduction |

**Interpretation**: On synthetic data where the factor model specification is correct, all optimization approaches dominate the naive benchmark. On real data, the equal-weight portfolio's implicit diversification proves remarkably robust—a result that underscores the gap between theoretical optimality and empirical performance.

### Learnable Risk Aversion

The E2E models successfully learn κ ≈ 0.11 across both environments, significantly lower than the baseline κ=1.0. This indicates the model prefers less aggressive risk penalization, adapting to data characteristics without manual tuning.

### Diversification Constraints

| Configuration | Effective Holdings | Max Weight | Trade-off |
|--------------|-------------------|------------|-----------|
| Unconstrained | ~1-2 assets | 100% | Higher concentration risk |
| Constrained (20%) | ~5 assets | 20% | Better risk-adjusted returns |

Position limits increase diversification by approximately 5× while maintaining competitive Sharpe ratios and substantially improving Sortino ratios and drawdown profiles.

---

## Repository Structure

```
integrated-learning-optimization-portfolio-allocation/
├── README.md                    # This file
├── src/                         # Source code
│   ├── e2edro/                  # End-to-end DRO library
│   └── README.md                # API documentation
├── outputs/
│   ├── reports/                 # Validation notebooks
│   │   ├── mv_validation_synthetic_report.ipynb
│   │   └── mv_validation_real_report.ipynb
│   └── figures/                 # Extracted visualizations
├── docs/
│   └── EXECUTIVE_SUMMARY.md     # High-level findings
└── references/                  # Academic papers
```

---

## Technical Stack

### Key Dependencies
| Package | Purpose |
|---------|---------|
| **torch** | Autograd, neural networks, optimization |
| **cvxpy** | Convex optimization modeling |
| **cvxpylayers** | Differentiable optimization layers |
| **pandas** | Data manipulation |
| **numpy** | Numerical computing |

---

## Original Source

This library is adapted from the **E2E-DRO** repository by Iyengar Lab (Columbia University):

- **Repository**: [github.com/Iyengar-Lab/E2E-DRO](https://github.com/Iyengar-Lab/E2E-DRO)
- **Paper**: [Distributionally Robust End-to-End Portfolio Construction](https://arxiv.org/abs/2206.05134)
- **Authors**: Giorgio Costa, Garud Iyengar
- **Published**: Quantitative Finance, Vol. 23, No. 10 (2023)

---

## Reference Papers

See `references/` directory for full papers:
- Distributionally Robust End-to-End Portfolio Construction
- Decision-Focused Learning: Foundations, State of the Art
- OptNet: Differentiable Optimization as a Layer in Neural Networks
- Smart Predict then Optimize (SPO)

---

## Project Status

**Status**: ✅ Complete (January 2025)

### Completed Phases
- Synthetic data generation and calibration
- Model implementation (PO and SPO variants)
- Rolling window backtesting
- Performance comparison and analysis
- Documentation and figure extraction

---

**Last Updated**: January 2025
