# State-Space Modeling for Asset Allocation

A comprehensive validation study of state-space models (SSM) for filtering financial time series and their impact on portfolio allocation performance.

## Overview

This project evaluates whether filtering financial returns through state-space models improves two-asset portfolio allocation compared to using raw (unfiltered) data.

### Research Question
**Does state-space filtering improve portfolio allocation performance?**

Compare allocation results using:
1. **Raw returns** (no filtering)
2. **Gaussian AR(1) SSM** filtered returns
3. **Student-t AR(1) SSM** filtered returns (robust to outliers)

### Asset Universe
- **TSX Composite Index** (^GSPTSE) - Canadian equity market
- **Canadian 3-Month T-Bills** - Risk-free asset

### Allocation Methods Evaluated
1. **Mean-Variance (MV)** - Classical Markowitz optimization
2. **CVaR** - Conditional Value-at-Risk minimization
3. **Omega Ratio** - Threshold-based optimization
4. **MVBU** - Mean-Variance with Box Uncertainty (Robust)

---

## 📊 View the Results

### Executive Summary (Recommended Starting Point)
→ [docs/EXECUTIVE_SUMMARY.md](docs/EXECUTIVE_SUMMARY.md)
- High-level findings and recommendations
- SSM filtering effectiveness analysis
- Model comparison insights
- Ideal for stakeholders and decision-makers

### Analysis Reports
- Jupyter notebooks and R markdown files available in `outputs/reports/`
- **Note**: Clone the repository to view full analysis locally

---

## Key Methodology

### Phase 1: Data Import & Preparation
- Download TSX index prices and Canadian T-bill rates
- Calculate log returns for TSX
- Convert T-bill annual rates to period returns
- Time period: 2015-01-01 to present

### Phase 2: State-Space Model Estimation
**Gaussian AR(1) SSM:**
```
State:       x_t = φ × x_{t-1} + η_t,  η_t ~ N(0, σ²_η)
Observation: y_t = x_t + ε_t,          ε_t ~ N(0, σ²_ε)
```

**Student-t AR(1) SSM:**
- Same structure as Gaussian
- Robust to outliers via Student-t innovations
- Estimated degrees of freedom

**Implementation:**
- Gaussian: R/KFAS package (Kalman filter)
- Student-t: R/pomp package (particle filter)

### Phase 3: Forecast Comparison
Rolling window forecast evaluation:
- **Metrics**: MAE, RMSE, Bias, Hit Rate, Directional Accuracy
- **Windows**: 5-day ahead forecasts over full test period
- **Comparison**: Raw vs. Gaussian-filtered vs. Student-t-filtered

### Phase 4: Portfolio Allocation
Multi-language implementation:
- **Julia**: All 4 methods (MV, CVaR, Omega, MVBU)
- **Python**: Mean-Variance for cross-validation

**Performance Metrics:**
- Sharpe Ratio
- Maximum Drawdown
- Cumulative Wealth
- Turnover

---

## Repository Structure

```
state-space-modeling/
├── README.md                    # This file
├── src/                         # Source code (API only)
│   └── README.md                # Public API documentation
├── outputs/
│   ├── reports/                 # Analysis reports (HTML excluded)
│   └── data/                    # Summary statistics and results
├── data/                        # Sample data (full data excluded)
│   ├── raw/                     # TSX + T-bill sample data
│   ├── filtered/                # SSM filtered outputs (sample)
│   └── comparison/              # Forecast comparison results
├── docs/
│   └── EXECUTIVE_SUMMARY.md     # High-level findings (public)
└── tests/                       # Test suite (structure only)
```

**Note**: Source code (R, Julia, Python scripts) and full datasets are excluded from the repository. API documentation and summary results are provided for reproducibility reference.

---

## Technical Stack

### Languages & Tools
- **R**: Data import, SSM estimation (KFAS, pomp), forecast comparison
- **Julia**: Portfolio optimization (JuMP, Ipopt)
- **Python**: Cross-validation allocation (scipy.optimize)

### Key Packages
- **R**: tidyquant, KFAS, pomp, tidyverse
- **Julia**: JuMP, Ipopt, DataFrames, CSV
- **Python**: pandas, numpy, scipy

### Integration Pattern
File-based (CSV) data exchange between R, Julia, and Python components

---

## Project Status

**Status**: ✅ Complete (January 2025)

**Deliverables:**
- SSM estimation and filtering complete
- Forecast comparison analysis complete
- Portfolio allocation across 3 scenarios complete
- Comparative validation report complete

**Next Steps:**
- Potential extension to multivariate SSMs
- Additional allocation methods
- Real-time deployment framework

---

## Key References

### State-Space Modeling
- Durbin & Koopman (2012): *Time Series Analysis by State Space Methods*
- Commandeur & Koopman (2007): *An Introduction to State Space Time Series Analysis*

### Portfolio Optimization
- Markowitz (1952): "Portfolio Selection"
- Rockafellar & Uryasev (2000): "Optimization of Conditional Value-at-Risk"

---

## Design Principles

### 1. Controlled Comparison
- Same data, same time periods across all scenarios
- Consistent allocation methods for fair comparison
- Rolling window validation for robustness

### 2. Multi-Language Validation
- Cross-validation between Julia and Python implementations
- Leverages strengths of each language (R for SSM, Julia for optimization)

### 3. Reproducibility
- Documented methodology
- Clear data processing pipeline
- API documentation for replication

---

## Contact

For questions about the methodology or results:
- Review the [Executive Summary](docs/EXECUTIVE_SUMMARY.md) for key findings
- Check the API documentation in `src/README.md`

---

**Last Updated**: January 2025
