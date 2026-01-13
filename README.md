# Quantitative Portfolio Research

Research studies exploring portfolio optimization methods, return filtering techniques, and machine learning integration for asset allocation.

## Projects

### 1. Portfolio Optimization Models
**Status**: Complete (January 2025)

Comparison of 5 portfolio optimization methods on synthetic data with known statistical properties.

**Models**: Mean-Variance, CVaR, Omega Ratio, MVBU (Box Uncertainty), MVEU (Ellipsoid Uncertainty)

**Key Finding**: Omega Ratio achieves best risk-adjusted performance (Sharpe 1.32); MVEU provides 9x higher capacity for institutional scale.

→ [Project README](portfolio-allocation-models/synthetic_data_validation/README.md) | [Executive Summary](portfolio-allocation-models/synthetic_data_validation/docs/EXECUTIVE_SUMMARY.md)

---

### 2. State-Space Modeling for Asset Allocation
**Status**: Complete (January 2025)

Evaluates whether filtering returns through state-space models improves portfolio allocation vs. using raw data.

**Approaches**: Raw returns (baseline), Gaussian AR(1) SSM (Kalman filter), Student-t AR(1) SSM (particle filter)

**Key Finding**: Student-t filtering yields +93% higher average return vs. unfiltered; best during volatile regimes.

→ [Project README](state-space-modeling/README.md) | [Executive Summary](state-space-modeling/docs/EXECUTIVE_SUMMARY.md)

---

### 3. Integrated Learning for Portfolio Optimization
**Status**: Complete (January 2025)

Compares Predict-then-Optimize (PO) vs. Smart Predict-then-Optimize (SPO/Decision-Focused Learning) for Mean-Variance portfolios with learnable risk aversion.

**Models**: Equal Weight, PO-MV, SPO-MV, and constrained variants

**Key Finding**: SPO successfully learns optimal risk aversion end-to-end; constrained models reduce drawdowns and turnover on real data.

→ [Project README](integrated-learning-optimization-portfolio-allocation/README.md) | [Executive Summary](integrated-learning-optimization-portfolio-allocation/docs/EXECUTIVE_SUMMARY.md)

---

## Technical Stack

| Language | Purpose |
|----------|---------|
| **Julia** | Portfolio optimization (JuMP, HiGHS/Ipopt) |
| **R** | State-space modeling (KFAS, pomp), data processing |
| **Python** | Decision-focused learning (PyTorch, cvxpylayers) |

---

## Limitations

These are research studies with educational scope. Key limitations across all projects:

- **Asset universe**: 2-30 assets (production systems handle 100-1000+)
- **Data history**: ~10 years (institutional studies use 20-30+)
- **No transaction costs**: Net returns would differ
- **Rolling window only**: No true holdout validation
- **Limited statistical rigor**: Basic tests only (production requires bootstrap CI, Diebold-Mariano tests)
- **No risk decomposition**: Factor attribution not implemented
- **No stress testing**: Crisis scenario analysis limited

See individual project executive summaries for detailed limitations.

---

## Validation Methodology

The studies incorporate principles from SR 11-7 (Model Risk Management) including multi-model comparison, controlled testing, out-of-sample backtesting, and benchmarking. See [docs/SR11-7_COMPLIANCE_MAPPING.md](docs/SR11-7_COMPLIANCE_MAPPING.md) for details and scope clarification.

---

## Repository Structure

```
quant-portfolio-research/
├── portfolio-allocation-models/       # Portfolio optimization comparison
│   └── synthetic_data_validation/
├── state-space-modeling/              # SSM filtering for allocation
├── integrated-learning-optimization-portfolio-allocation/  # SPO vs PO
└── docs/                              # Cross-project documentation
```

---

**Last Updated**: January 2025
