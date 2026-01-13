# Executive Summary: Integrated Learning for Portfolio Optimization

## Study Overview

This report presents a validation study comparing **Predict-then-Optimize (PO)** and **Smart Predict-then-Optimize (SPO/Decision-Focused Learning)** approaches for Mean-Variance portfolio construction with learnable risk aversion.

### Two Paradigms Compared
1. **Predict-then-Optimize (PO)**: Traditional two-stage approach - predict returns first, then optimize
2. **Smart Predict-then-Optimize (SPO)**: Decision-focused learning - train prediction model end-to-end with the optimization objective

### Models Evaluated
| Model | Type | Risk Aversion | Constraints |
|-------|------|---------------|-------------|
| **EW** | Benchmark | N/A | Equal weight 1/n |
| **PO-MV** | Predict-then-Optimize | Fixed κ=1.0 | Unconstrained |
| **PO-MV-Constr** | Predict-then-Optimize | Fixed κ=1.0 | max_weight=20% |
| **SPO-MV** | Smart Predict-then-Optimize | Learnable κ | Unconstrained |
| **SPO-MV-Constr** | Smart Predict-then-Optimize | Learnable κ | max_weight=20% |

**Status**: Complete (January 2025)

---

## Performance Results

### Synthetic Data (Calibrated, 665 observations)

| Model | Ann. Return | Sharpe | Sortino | Max DD | Turnover | Eff. Holdings |
|-------|-------------|--------|---------|--------|----------|---------------|
| **EW** | 22.13% | 2.31 | 3.90 | -8.80% | 0.00 | 20.0 |
| **PO-MV** | 133.22% | **9.40** | 11.97 | -6.70% | 95.36 | 1.1 |
| **PO-MV-Constr** | 87.39% | 8.36 | **18.32** | **-4.68%** | 75.27 | 5.0 |
| **SPO-MV** | 124.58% | 8.54 | 12.51 | -8.23% | 91.23 | 1.2 |
| **SPO-MV-Constr** | 77.42% | 7.15 | 13.98 | -4.78% | **64.91** | 5.1 |

**Key Observations (Synthetic)**:
- All optimized models dramatically outperform EW (Sharpe 7-9 vs 2.3)
- **Best Sharpe**: PO-MV (9.40) - model assumptions hold on synthetic data
- **Best Sortino**: PO-MV-Constr (18.32) with lowest drawdown (-4.68%)
- **Lowest Turnover**: SPO-MV-Constr (64.91) among optimized models
- **Learned κ**: 2.74 (from initial 1.83, +50% change)

### Real Market Data (2000-2025, ~1,325 observations)

| Model | Ann. Return | Sharpe | Sortino | Max DD | Turnover | Eff. Holdings |
|-------|-------------|--------|---------|--------|----------|---------------|
| **EW** | 16.67% | **1.06** | 1.25 | -30.42% | 0.00 | 20.0 |
| **PO-MV** | 26.16% | 0.94 | **1.47** | -44.68% | 87.07 | 1.7 |
| **PO-MV-Constr** | 17.51% | 0.85 | 1.14 | -35.31% | 70.30 | 5.2 |
| **SPO-MV** | 17.53% | 0.88 | 1.35 | -34.19% | 61.98 | 2.7 |
| **SPO-MV-Constr** | 17.00% | 0.98 | 1.27 | **-30.10%** | **26.86** | 5.3 |

**Key Observations (Real Data)**:
- **Best Sharpe**: EW (1.06), but SPO models achieve better Sortino (1.27-1.35 vs 1.25)
- **Best among optimized**: SPO-MV-Constr (0.98 Sharpe, -30.10% max drawdown)
- **Lowest Turnover**: SPO-MV-Constr (26.86) - 62% lower than PO-MV-Constr
- **Learned κ**: 4.0 (from initial 1.83, +118% change)

---

## Research Questions Answered

### 1. Decision-Focused vs. Sequential-Learning Optimization

**Question**: Does training the prediction model with awareness of the downstream optimization objective lead to better portfolio decisions than the traditional two-stage approach?

**Answer**: **Context-dependent.**
- **Synthetic data**: PO slightly outperforms SPO (Sharpe 9.40 vs 8.54) when model assumptions hold perfectly
- **Real data**: SPO-MV-Constr outperforms PO-MV-Constr (Sharpe 0.98 vs 0.85, drawdown -30% vs -35%, turnover 27 vs 70)
- SPO shows advantages in turnover reduction and drawdown protection on real data

### 2. Learnable vs. Fixed Risk Preferences

**Question**: Can the model discover an optimal risk aversion coefficient (κ) through gradient-based learning?

**Answer**: **Yes.** The SPO model successfully learns κ through gradient-based optimization:

| Dataset | Initial κ | Learned κ | Change |
|---------|-----------|-----------|--------|
| Synthetic | 1.83 | 2.74 | +50% |
| Real | 1.83 | 4.00 | +118% |

The model learned higher risk aversion on real data (volatile environment), demonstrating data-driven adaptation.

### 3. Synthetic vs. Real Market Performance

**Question**: How does the relative advantage of SPO over PO transfer from a controlled synthetic environment to real market data?

**Answer**: **Performance dynamics differ substantially:**

| Metric | Synthetic | Real |
|--------|-----------|------|
| Best Sharpe | PO-MV (9.40) | EW (1.06) |
| PO vs SPO | PO slightly better | SPO better on Sortino/drawdown |
| EW vs Optimized | Optimized dominates | EW competitive |

On synthetic data where model assumptions hold, optimization approaches achieve Sharpe ratios of 7-9. On real data, the EW benchmark achieves the highest Sharpe, but SPO outperforms on Sortino and drawdown metrics.

### 4. Portfolio Concentration Trade-offs

**Question**: What is the impact of diversification constraints on risk-adjusted returns?

**Answer**: **Constraints substantially improve risk metrics on both datasets:**

| Dataset | Config | Eff. Holdings | Max DD | Turnover |
|---------|--------|---------------|--------|----------|
| Synthetic | Unconstrained | 1.1-1.2 | -7% to -8% | 91-95 |
| Synthetic | Constrained | 5.0-5.1 | -4.7% to -4.8% | 65-75 |
| Real | Unconstrained | 1.7-2.7 | -34% to -45% | 62-87 |
| Real | Constrained | 5.2-5.3 | -30% to -35% | 27-70 |

The `max_weight=20%` constraint increases diversification by ~4-5x while improving drawdowns and reducing turnover.

---

## Strategic Recommendations

### Model Selection Guide

| Investor Profile | Recommended Model | Rationale |
|-----------------|------------------|-----------|
| **Simplicity-focused** | EW | Competitive Sharpe on real data, zero turnover |
| **Risk-averse** | SPO-MV-Constr | Best drawdown protection, lowest turnover |
| **Return-focused** | PO-MV | Highest returns (accepts high volatility) |
| **Diversification-focused** | SPO-MV-Constr | ~5 effective holdings, balanced metrics |

### When to Use Decision-Focused Learning

| Scenario | Recommendation | Rationale |
|----------|---------------|-----------|
| **Unknown optimal κ** | SPO | Learns risk aversion automatically |
| **Turnover-sensitive** | SPO-MV-Constr | 62% lower turnover than PO on real data |
| **Drawdown-sensitive** | SPO-MV-Constr | Best max drawdown among optimized |
| **Well-specified model** | PO | Slightly better Sharpe when assumptions hold |

---

## Methodology

### Mean-Variance Optimization Layer
```
maximize:  μᵀw - κ wᵀΣw
subject to: w ≥ 0, 1ᵀw = 1, w ≤ max_weight (optional)
```

### Data Sources

**Synthetic Data**:
- 20 assets, 8 factors, 665 observations
- Calibrated to historical market statistics
- Volatility regime changes (low → normal → high)

**Real Market Data**:
- 20 US stocks across sectors (AAPL, MSFT, JPM, XOM, etc.)
- 8 Fama-French factors
- Period: 2000-2025 (~1,325 weekly observations)

---

## Limitations & Future Work

### Current Study Limitations

**Data Constraints:**
- **20 assets only**: Production systems typically handle 100-1000+ assets with sector/factor constraints
- **Weekly frequency**: Daily data would provide more observations but higher noise
- **US equities only**: Not validated on international markets, fixed income, or alternatives

**Missing Production Elements:**
- **No transaction costs**: Turnover reported but not penalized in optimization; net returns would differ
- **No statistical significance tests**: Missing bootstrap confidence intervals, paired strategy comparisons
- **No risk decomposition**: Factor attribution and marginal risk contribution not computed
- **Limited stress testing**: Regime changes present but not explicit crisis scenario analysis
- **Rolling window only**: No true holdout set; all data used in walk-forward validation

**Model Constraints:**
- **Mean-Variance only**: SPO framework could extend to CVaR, Omega, or other objectives
- **Linear factor model**: Non-linear feature engineering not explored
- **Fixed constraint levels**: max_weight=20% not optimized; sensitivity analysis limited

### Future Work
1. **Scale to production universe**: 100+ assets with sector constraints and turnover limits
2. **Transaction cost integration**: Include turnover penalty in SPO loss function
3. **Statistical rigor**: Bootstrap confidence intervals, Diebold-Mariano tests for forecast comparison
4. **Alternative objectives**: Extend SPO to CVaR, drawdown-constrained, or multi-objective optimization
5. **True out-of-sample**: Reserve final 2-3 years as untouched holdout for final validation

---

## Conclusion

This validation study demonstrates that:

1. **Decision-focused learning works**: SPO models successfully learn risk aversion parameters (+50% on synthetic, +118% on real data)
2. **Context matters**: PO performs best on synthetic data; SPO shows advantages on real data (Sortino, drawdown, turnover)
3. **Diversification constraints are valuable**: Increase effective holdings from ~1 to ~5 assets while improving risk metrics
4. **SPO practical benefits on real data**: 62% lower turnover and 5pp better drawdown vs PO with constraints

**Bottom Line**: On synthetic data where model assumptions hold, PO achieves the best Sharpe ratio. On real market data, SPO-MV-Constr offers the best risk-adjusted performance among optimized models with substantially lower turnover and better drawdown protection. The choice between PO and SPO depends on whether model assumptions are expected to hold.

---

## For More Details

- **API Documentation**: [src/README.md](../src/README.md)
- **Reference Papers**: See `references/` directory

---

**Report Generated**: Integrated Learning for Portfolio Optimization
**Date**: January 2025
**Status**: Complete
