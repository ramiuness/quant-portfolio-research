# Model Validation Framework

A comprehensive collection of rigorous validation studies across quantitative modeling domains, emphasizing reproducibility, statistical rigor, and practical interpretability.

## 🎯 Philosophy

This repository showcases a systematic approach to model validation that prioritizes:

- **Controlled Environments**: Testing on synthetic data with known ground truth before real-world application
- **Comparative Analysis**: Multi-model evaluation to understand trade-offs and performance characteristics
- **Statistical Rigor**: Comprehensive metrics, hypothesis testing, and uncertainty quantification
- **Reproducibility**: Full code, documentation, and methodology transparency
- **Practical Insights**: Actionable recommendations for model selection and deployment

---

## 📚 Validation Projects

### ✅ Portfolio Optimization Models

**Status**: Phase 1 Complete (Synthetic Data Validation)

Comprehensive validation of classical and robust portfolio optimization approaches on controlled synthetic data.

**Location**: [`portfolio-allocation-models/synthetic-data/`](portfolio-allocation-models/synthetic-data/)

**Models Evaluated**:
- Mean-Variance (Classical)
- CVaR (Conditional Value-at-Risk)
- Omega Ratio
- Mean-Variance Box-Uncertainty (Robust)
- Mean-Variance Ellipsoid-Uncertainty (Robust)

**Key Findings**:
- **Best Performance**: Omega Ratio (annualized Sharpe: 1.32, IR: 0.78)
- **Maximum Capacity**: MVEU (28.33 effective bets, 9x classical models)
- **Trade-off Identified**: Performance vs. scalability (Omega vs. MVEU)

**Quick Links**:
- [Executive Summary](portfolio-allocation-models/synthetic_data_validation/docs/EXECUTIVE_SUMMARY.md) - High-level findings
- [Full Analysis Report](portfolio-allocation-models/synthetic_data_validation/README.md) - Complete documentation
- [Jupyter Notebook](portfolio-allocation-models/synthetic_data_validation/outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb) - Technical analysis

---

### ✅ State-Space Modeling for Asset Allocation

**Status**: Complete (January 2025)

Validation study evaluating whether state-space model filtering of financial returns improves portfolio allocation performance.

**Location**: [`state-space-modeling/`](state-space-modeling/)

**Research Question**: Does SSM filtering improve portfolio allocation vs. raw returns?

**Filtering Scenarios**:
- Raw returns (baseline)
- Gaussian AR(1) SSM filtered (Kalman filter)
- Student-t AR(1) SSM filtered (particle filter - robust to outliers)

**Key Findings**:
- **Student-t SSM**: Superior performance during volatile periods and crisis regimes
- **Gaussian SSM**: Effective noise reduction for stable markets
- **CVaR + Student-t**: Best combination for tail-risk management (~20% drawdown reduction)
- **Multi-language validation**: Julia/Python cross-validation confirmed implementation correctness

**Quick Links**:
- [Executive Summary](state-space-modeling/docs/EXECUTIVE_SUMMARY.md) - High-level findings
- [Full Documentation](state-space-modeling/README.md) - Complete methodology
- [API Documentation](state-space-modeling/src/README.md) - Technical implementation details

---

### ✅ Integrated Learning for Portfolio Optimization

**Status**: Complete (January 2025)

Validation study comparing **Predict-then-Optimize (PO)** vs **Smart Predict-then-Optimize (SPO/Decision-Focused Learning)** approaches for Mean-Variance portfolio construction.

**Location**: [`integrated-learning-optimization-portfolio-allocation/`](integrated-learning-optimization-portfolio-allocation/)

**Research Question**: Does end-to-end learning of risk aversion (κ) improve portfolio performance vs. fixed parameters?

**Models Evaluated**:
- Equal Weight (Benchmark)
- PO-MV: Predict-then-Optimize with fixed κ
- E2E-MV-Learned: End-to-end learning with learnable κ
- Constrained variants with max_weight diversification

**Key Findings**:
- **Learnable κ**: Model successfully learns optimal risk aversion end-to-end
- **Diversification constraints**: `max_weight` effectively increases holdings from ~1 to ~5 assets
- **Synthetic vs Real**: SPO shows promise on synthetic data; real market results more nuanced

**Quick Links**:
- [Executive Summary](integrated-learning-optimization-portfolio-allocation/docs/EXECUTIVE_SUMMARY.md) - High-level findings
- [API Documentation](integrated-learning-optimization-portfolio-allocation/src/README.md) - e2edro library reference
- [Synthetic Data Validation](integrated-learning-optimization-portfolio-allocation/outputs/reports/mv_validation_synthetic_report.ipynb) - Controlled environment testing
- [Real Data Validation](integrated-learning-optimization-portfolio-allocation/outputs/reports/mv_validation_real_report.ipynb) - Market data evaluation

**Reference Papers** (in `references/`):
- Distributionally Robust End-to-End Portfolio Construction
- Decision-Focused Learning: Foundations, State of the Art
- OptNet: Differentiable Optimization as a Layer in Neural Networks
- Smart Predict then Optimize (SPO)

---

### 🔄 Additional Validation Projects

**Status**: In Progress

Additional validation studies in quantitative modeling are currently in development:
- **Stochastic Volatility Models for TSX**: Validation of GARCH, EGARCH, and stochastic volatility models for modeling TSX index volatility dynamics

---

## 🔬 Validation Methodology

### Common Framework Across Projects

All validation studies in this repository follow a consistent framework:

#### Phase A: Synthetic Data Validation
1. **Data Generation**: Create controlled synthetic datasets with known properties
2. **Model Implementation**: Implement all candidate models with consistent parameters
3. **Technical Validation**: Verify constraints, convergence, and numerical stability
4. **Comparative Analysis**: Evaluate performance across multiple dimensions
5. **Documentation**: Comprehensive reporting with reproducible results

#### Phase B: Real-World Validation
1. **Data Preparation**: Clean, validated real-world datasets
2. **Out-of-Sample Testing**: Proper train/test splits, walk-forward validation
3. **Robustness Analysis**: Performance across market regimes and time periods
4. **Practical Assessment**: Transaction costs, implementation constraints

#### Phase C: Comparative Synthesis
1. **Synthetic vs. Real**: Identify where synthetic results hold/diverge
2. **Model Selection Guidelines**: Context-dependent recommendations
3. **Risk Assessment**: Failure modes and edge cases
4. **Production Readiness**: Deployment considerations

---

## 📊 Key Themes Across Validations

### 1. Performance Metrics
- Risk-adjusted returns (Sharpe, Sortino, Information Ratios)
- Absolute and relative performance measures
- Annualized reporting for interpretability

### 2. Model Characteristics
- Diversification and concentration analysis
- Capacity and scalability assessment
- Computational efficiency

### 3. Robustness vs. Performance
- Classical vs. robust approaches
- Performance-stability trade-offs
- Parameter sensitivity analysis

### 4. Practical Considerations
- Implementation complexity
- Computational requirements
- Data requirements and estimation risk

---

## 🛠️ Technical Stack

### Languages & Tools
- **Julia**: Primary language for optimization and numerical computing
- **R**: State-space modeling, time series analysis, statistical estimation
- **Python**: Data processing and alternative implementations
- **Jupyter**: Interactive analysis and reporting
- **Git**: Version control and reproducibility

### Key Libraries
- **Julia**: JuMP, Ipopt, DataFrames.jl, Plots.jl, Distributions.jl
- **R**: KFAS (Kalman filter), pomp (particle filter), tidyquant, tidyverse
- **Python**: pandas, numpy, scipy, matplotlib, torch, cvxpy, cvxpylayers

---

## 📖 Documentation Standards

Each validation project includes:

### Essential Documentation
- **README.md**: Project overview, quick start, key findings
- **EXECUTIVE_SUMMARY.md**: High-level insights for stakeholders
- **Methodology docs**: Detailed technical documentation

### Code Organization
- **`src/`**: Source code (models, metrics, utilities)
- **`outputs/`**: Results (reports, figures, data)
- **`tests/`**: Validation tests (private - structure only)
- **`docs/`**: Documentation (private - structure only)

### Reproducibility
- All results reproducible from source code
- Seeds specified for stochastic processes
- Dependencies documented
- Relative paths (no hardcoded absolute paths)

---

## 🚀 Getting Started

### Prerequisites
- Julia 1.6+ or Python 3.8+
- Jupyter Notebook
- Git

### Quick Start

```bash
# Clone the repository
git clone https://github.com/[your-username]/model-validation.git
cd model-validation

# Navigate to a specific validation project
cd portfolio-allocation-models/synthetic-data/

# Follow project-specific README for setup and execution
```

---

## 📁 Repository Structure

```
model-validation/
├── README.md                                    # This file
├── .gitignore                                   # Git exclusions
│
├── portfolio-allocation-models/                 # Portfolio optimization validation
│   └── synthetic_data_validation/               # Phase 1: Synthetic data
│       ├── README.md                            # Project documentation
│       ├── src/                                 # Source code (API only)
│       │   └── README.md                        # Public API documentation
│       ├── outputs/                             # Results and reports
│       │   ├── figures/                         # Visualizations
│       │   └── reports/                         # Jupyter notebooks
│       ├── tests/                               # Test suite (structure only)
│       └── docs/                                # Documentation (structure only)
│           └── EXECUTIVE_SUMMARY.md             # High-level findings
│
├── state-space-modeling/                        # SSM filtering for allocation
│   ├── README.md                                # Project documentation
│   ├── src/                                     # Source code (API only)
│   │   └── README.md                            # Public API documentation
│   ├── outputs/                                 # Results and reports
│   │   ├── reports/                             # Analysis reports
│   │   └── data/                                # Summary statistics
│   ├── data/                                    # Sample data
│   │   ├── raw/                                 # TSX + T-bill sample
│   │   ├── filtered/                            # SSM filtered outputs
│   │   └── allocation/                          # Allocation results
│   ├── tests/                                   # Test suite (structure only)
│   └── docs/                                    # Documentation (structure only)
│       └── EXECUTIVE_SUMMARY.md                 # High-level findings
│
└── integrated-learning-optimization-portfolio-allocation/  # Decision-focused learning
    ├── src/                                     # Source code (structure only)
    │   └── e2edro/                              # End-to-end DRO library
    ├── outputs/                                 # Results and reports
    │   └── reports/                             # Validation notebooks
    └── references/                              # Academic papers
```

---

## 🎓 Principles

### Statistical Rigor
- **No p-hacking**: Pre-specified validation criteria
- **Proper uncertainty quantification**: Confidence intervals, bootstrapping
- **Multiple comparison corrections**: When testing multiple models
- **Out-of-sample validation**: Avoiding overfitting to validation data

### Transparency
- **Full methodology disclosure**: No black boxes
- **Code availability**: All implementations public
- **Limitation acknowledgment**: Clear statement of assumptions and constraints
- **Negative results**: Reporting what doesn't work is valuable

### Practical Relevance
- **Real-world constraints**: Transaction costs, market impact, liquidity
- **Implementability**: Can this be deployed in production?
- **Interpretability**: Understanding why models work or fail
- **Actionable insights**: Clear guidance for practitioners

---

## 🔗 Related Resources

### Academic References
- Grinold & Kahn (1999): *Active Portfolio Management*
- DeMiguel, Garlappi & Uppal (2009): "Optimal Versus Naive Diversification"
- CFA Institute: *Global Investment Performance Standards (GIPS)*

### Technical Resources
- [JuMP.jl Documentation](https://jump.dev/)
- [Julia Documentation](https://docs.julialang.org/)
- [Portfolio Optimization Literature](https://scholar.google.com/)

---

## 📄 License

This repository is for research and educational purposes. Individual projects may have specific licenses - refer to project directories.

---

## 📧 Contact

For questions, suggestions, or collaboration opportunities:
- Open an issue in this repository
- Reach out via GitHub discussions

---

## 🗓️ Project Status

| Project | Phase | Status | Last Updated |
|---------|-------|--------|--------------|
| Portfolio Optimization | Synthetic Data | ✅ Complete | January 2025 |
| State-Space Modeling | All Phases | ✅ Complete | January 2025 |
| Integrated Learning (SPO) | All Phases | ✅ Complete | January 2025 |
| Stochastic Volatility Models | - | 🔄 In Progress | - |

---

**Maintained by**: [Your Name]
**Last Updated**: January 2025
