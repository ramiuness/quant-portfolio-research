# Integrated Learning for Portfolio Optimization

A validation study comparing **Predict-then-Optimize (PO)** and **Smart Predict-then-Optimize (SPO)** approaches for Mean-Variance portfolio construction with learnable risk aversion.

## Overview

This project presents a validation study comparing two paradigms for integrating machine learning with portfolio optimization:

1. **Predict-then-Optimize (PO)**: The traditional two-stage approach where a model first predicts expected returns, then a separate optimization step constructs the portfolio treating predictions as given. This approach follows a sequential learning and optimization paradigm.

2. **Smart Predict-then-Optimize (SPO)**: An end-to-end approach where the prediction model is trained with direct awareness of the downstream optimization objective, allowing gradients to flow through the portfolio construction step. This approach follows the **Decision-Focused Learning** paradigm.

This work extends the framework established in *"Distributionally Robust End-to-End Portfolio Construction"* (Costa & Iyengar, Quantitative Finance, 2023). We apply decision-focused learning to Mean-Variance optimization with learnable risk aversion.

The study evaluates whether embedding optimization objectives directly into the learning process—allowing the model to jointly learn prediction parameters and risk preferences—yields superior portfolio outcomes compared to the traditional sequential paradigm.

---

## Research Questions

This study investigates several interconnected questions at the intersection of machine learning and portfolio theory:

1. **Decision-Focused vs. Sequential-Learning Optimization**: Does training the prediction model with awareness of the downstream optimization objective lead to better portfolio decisions than the traditional two-stage approach?

2. **Learnable vs. Fixed Risk Preferences**: Can the model discover an optimal risk aversion coefficient (κ) through gradient-based learning, and how does this data-driven parameterization compare to conventional fixed values?

3. **Synthetic vs. Real Market Performance**: How does the relative advantage of SPO over PO transfer from a controlled synthetic environment to real market data where model assumptions may be violated?

4. **Portfolio Concentration Trade-offs**: What is the impact of diversification constraints on risk-adjusted returns? How do constrained portfolios compare to unconstrained solutions in terms of Sharpe ratio, drawdown protection, and effective number of holdings?

<!-- 5. **Risk Aversion Sensitivity**: How robust are portfolio outcomes to the choice of κ, and does the learned value fall within a stable performance region? -->

---

## Methodology

### Factor-Based Return Prediction

Expected asset returns are modeled as linear functions of systematic risk factors, following the Arbitrage Pricing Theory tradition. We highligh the fact that the SPO pipeline allows the learning of the returns from the factors using multilayer neural networks. The feature set comprises **8 Fama-French factors**:

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

**Smart Predict-then-Optimize (SPO)**: The prediction model minimizes realized portfolio loss, computed by passing predictions through the optimization layer and evaluating against actual returns. This decision-focused objective aligns learning with the ultimate investment goal. We consider a loss function that is a combination of MSE a Sharpe ratio loss.

### Differentiable Optimization Layer

The Mean-Variance optimization problem is embedded into the prediction pipeline as a differentiable layer using cvxpylayers:

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
| **PO-MV-Constr** | Predict-then-Optimize | Fixed κ=1.0 | max_weight=20% |
| **SPO-MV** | Smart Predict-then-Optimize | Learnable κ | Unconstrained |
| **SPO-MV-Constr** | Smart Predict-then-Optimize | Learnable κ | max_weight=20% |

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

### Performance Summary (Real Market Data 2000-2025)

| Model | Ann. Return | Sharpe | Sortino | Max Drawdown | Turnover | Eff. Holdings |
|-------|-------------|--------|---------|--------------|----------|---------------|
| **EW** | 16.67% | **1.06** | 1.25 | -30.42% | 0.00 | 20.0 |
| **PO-MV** | 26.16% | 0.94 | **1.47** | -44.68% | 87.07 | 1.7 |
| **PO-MV-Constr** | 17.51% | 0.85 | 1.14 | -35.31% | 70.30 | 5.2 |
| **SPO-MV** | 17.53% | 0.88 | 1.35 | -34.19% | 61.98 | 2.7 |
| **SPO-MV-Constr** | 17.00% | 0.98 | 1.27 | **-30.10%** | **26.86** | 5.3 |

**Key Insights**:
- **Best Sharpe**: EW (1.06), but SPO models achieve better Sortino ratios (1.27-1.35 vs 1.25)
- **Best among optimized**: SPO-MV-Constr (0.98 Sharpe, lowest drawdown, lowest turnover)
- **Learned κ**: 4.0 (from initial 1.83, +118% change) - model learned higher risk aversion

### Learnable Risk Aversion

The SPO models successfully learn κ through gradient-based optimization, adapting risk preferences to market conditions. The learned value (κ=4.0) represents a data-driven choice that removes the need for manual tuning.

### Diversification Constraints

| Configuration | Effective Holdings | Max Drawdown | Turnover |
|--------------|-------------------|--------------|----------|
| Unconstrained | ~1.7-2.7 assets | -34% to -45% | 62-87 |
| Constrained (20%) | ~5.2-5.3 assets | -30% to -35% | 27-70 |

Position limits increase diversification by ~2-3x while substantially improving drawdown profiles and reducing turnover.

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
