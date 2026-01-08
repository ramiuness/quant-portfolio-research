# Source Code API

The source code implementation is private. This document describes the public API and usage patterns.

---

## Overview

This directory contains the core implementation for portfolio optimization model validation. The code is organized into four main modules:

1. **Optimization Models** (`robustOptimization.jl`)
2. **Metrics Computation** (`compute_metrics.jl`)
3. **Adaptive Optimization** (`adaptive_optimization.jl`)
4. **Visualization** (`visualize_themes.jl`)

---

## Module: robustOptimization.jl

Portfolio optimization model implementations.

### Available Models

```julia
# Mean-Variance (Classical)
optimize_mv(mean_rets, cov_matrix, target_ret) -> Dict

# Conditional Value-at-Risk
optimize_cvar(rets, mean_rets, beta, target_ret) -> Dict

# Omega Ratio
optimize_omega(rets, mean_rets, tau, delta_range) -> Dict

# Mean-Variance Box-Uncertainty (Robust)
optimize_mvbu(mean_rets, cov_matrix, cov_mean_est, target_ret, alpha) -> Dict

# Mean-Variance Ellipsoid-Uncertainty (Robust)
optimize_mveu(mean_rets, cov_matrix, cov_mean_est, target_ret, alpha) -> Dict
```

### Return Format

All optimization functions return a `Dict` with:
- `"weights"`: Vector{Float64} - Portfolio weights
- `"status"`: String - Solver status ("Success" or error message)
- `"objective"`: Float64 - Objective function value
- `"model"`: String - Model name

---

## Module: compute_metrics.jl

Comprehensive performance metrics computation.

### Main Functions

```julia
# Compute all metrics for a single portfolio
compute_portfolio_metrics(
    weights::Vector{Float64},
    rets::Matrix{Float64},
    mean_rets::Vector{Float64};
    benchmark_weights::Union{Vector{Float64}, Nothing} = nothing
) -> Dict{String, Float64}
```

**Returns metrics including:**
- Mean Return, Volatility, CVaR (95%)
- Sharpe Ratio, Sortino Ratio, Information Ratio
- Capacity (1/HHI), Invested Stocks, Max Weight
- Cumulative PnL

```julia
# Compute metrics for all models
compute_all_metrics(
    results::Dict,
    rets::Matrix{Float64},
    mean_rets::Vector{Float64};
    benchmark_weights::Union{Vector{Float64}, Nothing} = nothing
) -> DataFrame
```

**Returns:** DataFrame with one row per model, all metrics as columns

```julia
# Annualize daily metrics
annualize_metrics(
    metrics_df::DataFrame;
    trading_days::Int = 252
) -> DataFrame
```

**Annualization rules:**
- Returns: `(1 + daily)^252 - 1`
- Volatility: `daily × √252`
- Ratios (Sharpe, IR, Sortino): `daily × √252`

```julia
# Display formatted metrics table
print_metrics_table(
    metrics_df::DataFrame;
    columns::Vector{String} = all_columns,
    title::String = "METRICS",
    annualized::Bool = false
) -> Nothing
```

---

## Module: adaptive_optimization.jl

Adaptive target/threshold optimization system.

### Main Function

```julia
# Run all 5 models with adaptive optimization
run_models_adaptive(
    rets::Matrix{Float64},
    mean_rets::Vector{Float64},
    cov_matrix::Matrix{Float64},
    std_rets::Vector{Float64},
    target_ret::Float64;
    beta::Float64 = 0.95,
    tau::Float64 = 0.0,
    delta_range::Vector{Float64} = collect(0.6:0.05:0.85),
    alpha_mvbu::Float64 = 0.05,
    alpha_mveu::Float64 = 0.95
) -> Dict{String, Dict}
```

**Returns:** Dict with keys ["MV", "CVaR", "Omega", "MVBU", "MVEU"]

Each containing:
- `"weights"`, `"status"`, `"objective"`, `"model"`
- `"target_used"` (adjusted target if original was infeasible)

### Adaptive Behavior

- **Target models (MV, CVaR, MVBU, MVEU)**: If target return is infeasible, automatically reduces by 5% of achieved return
- **Threshold models (Omega)**: Validates return ≥ tau, adjusts tau if needed

See [docs/ADAPTIVE_TARGETS_README.md](../docs/ADAPTIVE_TARGETS_README.md) for details.

---

## Module: visualize_themes.jl

Thematic visualization functions.

### Theme Visualizations

```julia
# Theme 1: Performance Metrics
theme1_performance_metrics(
    metrics_df::DataFrame;
    save_fig::Bool = false
) -> Plot

# Theme 2: Diversification & Capacity
theme2_diversification_capacity(
    metrics_df::DataFrame;
    save_fig::Bool = false
) -> Plot

# Theme 3: Classical vs Robust
theme3_classical_vs_robust(
    metrics_df::DataFrame,
    results::Dict;
    save_fig::Bool = false
) -> Plot

# Theme 4: Risk-Return Trade-offs
theme4_risk_return_tradeoffs(
    metrics_df::DataFrame;
    save_fig::Bool = false
) -> Plot

# Bonus: Weight Heatmap
plot_weight_heatmap(
    results::Dict;
    save_fig::Bool = false
) -> Plot
```

### Generate All Visualizations

```julia
generate_all_visualizations(
    metrics_df::DataFrame,
    results::Dict;
    save_figs::Bool = true
) -> Tuple{Plot, Plot, Plot, Plot, Plot}
```

Saves to `outputs/figures/` when `save_figs=true`.

---

## Usage Example

See the [Jupyter notebook](../outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb) for complete usage. Basic workflow:

```julia
# 1. Load modules
include("src/robustOptimization.jl")
include("src/compute_metrics.jl")
include("src/adaptive_optimization.jl")
include("src/visualize_themes.jl")

# 2. Prepare data
rets = # ... your returns matrix (N × n_assets)
mean_rets = mean(rets, dims=1)
cov_matrix = cov(rets)
std_rets = std(rets, dims=1)

# 3. Run all models
results = run_models_adaptive(
    rets, mean_rets, cov_matrix, std_rets,
    target_ret = 0.0007
)

# 4. Compute metrics
benchmark = ones(n_assets) / n_assets  # 1/n
metrics_df = compute_all_metrics(results, rets, mean_rets,
                                 benchmark_weights=benchmark)

# 5. Visualize
theme1_performance_metrics(metrics_df, save_fig=true)
theme2_diversification_capacity(metrics_df, save_fig=true)
```

---

## Dependencies

### Required Packages
- **DataFrames.jl**: Data manipulation
- **CSV.jl**: File I/O
- **Statistics**: Statistical functions
- **LinearAlgebra**: Matrix operations
- **Distributions.jl**: Statistical distributions
- **Plots.jl**: Visualization
- **PrettyTables.jl**: Formatted table output
- **JuMP.jl**: Mathematical optimization
- **Ipopt.jl**: Nonlinear optimizer

### Installation

```julia
using Pkg
Pkg.add(["DataFrames", "CSV", "Statistics", "LinearAlgebra",
         "Distributions", "Plots", "PrettyTables", "JuMP", "Ipopt"])
```

---

## Design Principles

### 1. Separation of Concerns
- **Models** (robustOptimization.jl): Pure optimization logic
- **Metrics** (compute_metrics.jl): Performance measurement
- **Adaptation** (adaptive_optimization.jl): Robust execution
- **Visualization** (visualize_themes.jl): Presentation

### 2. Consistent Interface
All optimization functions:
- Accept similar parameter types
- Return standardized Dict format
- Include status/error information

### 3. Validation-Ready
All functions include:
- Input validation
- Error handling
- Status reporting

---

## Performance Notes

### Computational Complexity

| Model | Complexity | Typical Runtime (30 assets) |
|-------|-----------|----------------------------|
| MV | O(n²) | < 0.1s |
| CVaR | O(n × N) | ~ 0.5s |
| Omega | O(n × N × k) | ~ 2-5s |
| MVBU | O(n²) | < 0.1s |
| MVEU | O(n²) | < 0.1s |

Where:
- n = number of assets
- N = number of observations
- k = number of delta values in range

### Optimization Tips

1. **Use fewer delta values** for Omega (default: 6 values from 0.6 to 0.85)
2. **Pre-compute covariance matrices** if running multiple models
3. **Set solver tolerances** appropriately for your precision needs

---

## Testing

The implementation includes comprehensive tests in `tests/` (private).

Key validation performed:
- Constraint satisfaction (weights ≥ 0, sum = 1)
- Solver convergence
- Target achievement (with adaptive adjustment)
- Metric calculation accuracy
- Annualization correctness

---

## Reproducibility

All stochastic operations use specified seeds:
- Synthetic data generation: `seed=42`
- Monte Carlo (if used): Documented in function calls

---

## References

### Methodology
- [Information Ratio Methodology](../docs/INFORMATION_RATIO_METHODOLOGY.md)
- [Adaptive Targets System](../docs/ADAPTIVE_TARGETS_README.md)
- [Executive Summary](../docs/EXECUTIVE_SUMMARY.md)

### Academic
- Grinold & Kahn (1999): *Active Portfolio Management*
- DeMiguel et al. (2009): "Optimal Versus Naive Diversification"

---

## Support

For questions about the API:
1. Review the [Jupyter notebook](../outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb) for usage examples
2. Check the [Executive Summary](../docs/EXECUTIVE_SUMMARY.md) for methodology
3. Open an issue on GitHub

---

**Note**: The source code implementation is proprietary. This API documentation is provided to facilitate understanding and potential replication of the validation framework.
