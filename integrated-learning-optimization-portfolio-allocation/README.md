# Integrated Learning for Portfolio Optimization

A validation study comparing **Predict-then-Optimize (PO)** and **Smart Predict-then-Optimize (SPO/Decision-Focused Learning)** approaches for Mean-Variance portfolio construction with learnable risk aversion.

## Overview

This project evaluates whether end-to-end learning of optimization parameters improves portfolio performance compared to traditional two-stage approaches.

### Research Question
**Does end-to-end learning of risk aversion (κ) improve portfolio performance compared to fixed parameters?**

### Two Paradigms Compared
1. **Predict-then-Optimize (PO)**: Traditional two-stage approach - predict returns first, then optimize
2. **Smart Predict-then-Optimize (SPO)**: Decision-focused learning - train prediction model end-to-end with the optimization objective

### Models Evaluated
| Model | Type | Risk Aversion | Constraints |
|-------|------|---------------|-------------|
| **EW** | Benchmark | N/A | Equal weight 1/n |
| **PO-MV** | Predict-then-Optimize | Fixed κ=1.0 | Unconstrained |
| **PO-MV-Constrained** | Predict-then-Optimize | Fixed κ=1.0 | max_weight=20% |
| **E2E-MV-Learned** | Smart Predict-then-Optimize | Learnable κ | Unconstrained |
| **E2E-MV-Constrained** | Smart Predict-then-Optimize | Learnable κ | max_weight=20% |

---

## 📊 View the Results

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

## Key Findings at a Glance

### Learnable Risk Aversion Works
- E2E models successfully learn κ ≈ 0.11 (vs baseline κ=1.0)
- Model adapts to data characteristics without manual tuning

### Diversification Constraints Are Effective
| Model | Effective Holdings | Max Weight |
|-------|-------------------|------------|
| Unconstrained | ~1-2 assets | 100% |
| Constrained (20%) | ~5 assets | 20% |

### Performance Summary

**Synthetic Data** (Best Sharpe: PO-MV-Constrained = 0.85):
- All optimized models significantly outperform EW benchmark
- Constrained models achieve better Sortino ratios

**Real Data** (Best Sharpe: EW = 0.14):
- EW benchmark is competitive
- Constrained models show better risk management

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

### Differentiable Optimization
The optimization layer uses cvxpylayers to make the MV optimization differentiable, enabling gradient-based learning of κ through the optimization problem.

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
