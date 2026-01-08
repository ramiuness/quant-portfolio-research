# API Documentation: State-Space Modeling for Asset Allocation

This document provides an overview of the code structure and key functions used in the state-space modeling validation study. **Note**: Source code files are excluded from the repository; this serves as a reference for methodology and reproducibility.

---

## Project Architecture

### Multi-Language Pipeline

The project uses a **file-based integration pattern** with CSV data exchange:

```
R (SSM estimation) → CSV → Julia (allocation) → CSV → Python (validation)
                                    ↓
                              Comparison results
```

### Component Responsibilities

| Language | Purpose | Key Packages |
|----------|---------|--------------|
| **R** | Data import, SSM estimation, forecast comparison | KFAS, pomp, tidyquant, tidyverse |
| **Julia** | Portfolio optimization (all 4 methods) | JuMP, Ipopt, DataFrames, CSV |
| **Python** | Cross-validation, alternative MV implementation | pandas, numpy, scipy.optimize |

---

## Phase 1: Data Import (R)

### Script: `01_import_tsx_data.R`

**Purpose**: Download and prepare TSX index and T-bill data

**Key Functions**:
```r
# Download TSX index from Yahoo Finance
tq_get(x = "^GSPTSE", from = "2015-01-01", to = Sys.Date())

# Download Canadian T-bill rates
tq_get(x = "IRSTCI01CAM156N", from = "2015-01-01", get = "economic.data")

# Calculate log returns
log_returns <- diff(log(prices))

# Convert annual T-bill rates to period returns
period_return <- (1 + annual_rate/100)^(1/252) - 1
```

**Outputs**:
- `data/raw/tsx_index_prices.csv`
- `data/raw/tsx_index_returns.csv`
- `data/raw/tbill_rates.csv`

---

## Phase 2: State-Space Model Estimation (R)

### Script: `02_ar1_gaussian_ssm.Rmd`

**Purpose**: Estimate Gaussian AR(1) SSM using Kalman filtering

**Model Specification**:
```r
# State-space model structure
model <- SSModel(
  y ~ -1 + SSMcustom(
    Z = matrix(1),
    T = matrix(phi),      # AR(1) coefficient
    R = matrix(1),
    Q = matrix(sigma_eta^2),  # State variance
    P1 = matrix(sigma_eta^2 / (1 - phi^2))
  ),
  H = matrix(sigma_eps^2)  # Observation variance
)

# Kalman filter
kfs <- KFS(model)
filtered_states <- kfs$a  # Filtered state estimates
```

**Key Functions**:
- `SSModel()`: Define state-space structure
- `fitSSM()`: Maximum likelihood estimation of parameters (φ, σ²_η, σ²_ε)
- `KFS()`: Kalman filter and smoother

**Outputs**:
- `data/filtered/gaussian_filtered_states.csv`
- `data/filtered/gaussian_params.csv`

**Parameters Estimated**:
- `phi`: AR(1) coefficient (autocorrelation)
- `sigma_eta`: State innovation standard deviation
- `sigma_eps`: Observation noise standard deviation

---

### Script: `03_ar1_student_t_ssm.Rmd`

**Purpose**: Estimate Student-t AR(1) SSM using particle filtering

**Model Specification**:
```r
# pomp model definition
student_t_ssm <- pomp(
  data = tsx_returns,
  times = "date",
  t0 = 1,

  # State process (rprocess)
  rprocess = discrete_time(
    step.fun = function(x, phi, sigma_eta, ...) {
      x + rnorm(n = 1, mean = phi * x, sd = sigma_eta)
    }
  ),

  # Observation process (rmeasure) - Student-t noise
  rmeasure = function(x, sigma_eps, nu, ...) {
    x + rt(n = 1, df = nu) * sigma_eps
  },

  # Likelihood function (dmeasure)
  dmeasure = function(y, x, sigma_eps, nu, log, ...) {
    dt((y - x) / sigma_eps, df = nu, log = log)
  }
)

# Particle filter
pf_result <- pfilter(student_t_ssm, Np = 1000)
filtered_states <- pf_result$filter.mean
```

**Key Functions**:
- `pomp()`: Define particle filter model
- `pfilter()`: Run particle filter for state estimation
- `mif2()`: Iterated filtering for parameter estimation

**Outputs**:
- `data/filtered/student_t_filtered_states.csv`
- `data/filtered/student_t_params.csv`

**Parameters Estimated**:
- `phi`: AR(1) coefficient
- `sigma_eta`: State innovation standard deviation
- `sigma_eps`: Observation noise scale
- `nu`: Student-t degrees of freedom (heavy-tail parameter)

---

## Phase 3: Forecast Comparison (R)

### Script: `04_forecast_comparison.Rmd`

**Purpose**: Rolling window forecast evaluation across 3 scenarios (raw, Gaussian, Student-t)

**Rolling Forecast Function**:
```r
rolling_forecast <- function(data, window_size = 252, horizon = 5) {
  n <- nrow(data)
  forecasts <- list()

  for (t in window_size:(n - horizon)) {
    # Train on data[1:t]
    # Forecast for data[(t+1):(t+horizon)]
    train <- data[1:t, ]
    test <- data[(t+1):(t+horizon), ]

    # Fit SSM on training data
    model_fit <- fit_ssm(train)

    # Forecast
    forecast <- predict_ssm(model_fit, h = horizon)
    forecasts[[t]] <- forecast
  }

  return(forecasts)
}
```

**Evaluation Metrics**:
```r
# Mean Absolute Error
MAE <- mean(abs(actual - forecast))

# Root Mean Squared Error
RMSE <- sqrt(mean((actual - forecast)^2))

# Bias
Bias <- mean(forecast - actual)

# Hit Rate (directional accuracy)
HitRate <- mean(sign(actual) == sign(forecast))

# Statistical tests
dm_test <- dm.test(errors1, errors2)  # Diebold-Mariano test
```

**Outputs**:
- `outputs/data/forecast_metrics.csv`
- `outputs/data/forecast_summary.csv`
- `outputs/data/statistical_tests.csv`

---

## Phase 4: Portfolio Allocation

### Julia Implementation: `julia/05_julia_allocation.jl`

**Purpose**: Run all 4 allocation methods on all 3 filtered datasets

**1. Mean-Variance Optimization**:
```julia
function mean_variance_allocation(returns, rf_rate, target_return)
    model = Model(Ipopt.Optimizer)
    n = size(returns, 2)

    @variable(model, w[1:n] >= 0)  # Weights
    @constraint(model, sum(w) == 1)  # Fully invested
    @constraint(model, dot(mean(returns, dims=1), w) >= target_return)  # Target return

    # Minimize variance
    @objective(model, Min, w' * cov(returns) * w)

    optimize!(model)
    return value.(w)
end
```

**2. CVaR Optimization**:
```julia
function cvar_allocation(returns, rf_rate, alpha = 0.05)
    model = Model(Ipopt.Optimizer)
    n = size(returns, 2)
    T = size(returns, 1)

    @variable(model, w[1:n] >= 0)
    @variable(model, z >= 0)  # VaR threshold
    @variable(model, u[1:T] >= 0)  # Auxiliary variables

    @constraint(model, sum(w) == 1)

    # CVaR constraints
    for t in 1:T
        @constraint(model, u[t] >= -dot(returns[t, :], w) - z)
    end

    # Minimize CVaR
    @objective(model, Min, z + (1/alpha) * sum(u) / T)

    optimize!(model)
    return value.(w)
end
```

**3. Omega Ratio Optimization**:
```julia
function omega_allocation(returns, tau = 0.0)
    model = Model(Ipopt.Optimizer)
    n = size(returns, 2)
    T = size(returns, 1)

    @variable(model, w[1:n] >= 0)
    @variable(model, u[1:T] >= 0)  # Upside
    @variable(model, d[1:T] >= 0)  # Downside

    @constraint(model, sum(w) == 1)

    # Upside/downside decomposition
    for t in 1:T
        portfolio_return = dot(returns[t, :], w)
        @constraint(model, u[t] >= portfolio_return - tau)
        @constraint(model, d[t] >= tau - portfolio_return)
    end

    # Maximize Omega ratio (upside / downside)
    @objective(model, Max, sum(u) / (sum(d) + 1e-6))

    optimize!(model)
    return value.(w)
end
```

**4. Mean-Variance Box Uncertainty (MVBU)**:
```julia
function mvbu_allocation(returns, rf_rate, target_return, delta = 0.1)
    model = Model(Ipopt.Optimizer)
    n = size(returns, 2)

    mu = mean(returns, dims=1)
    Sigma = cov(returns)

    @variable(model, w[1:n] >= 0)
    @variable(model, lambda >= 0)  # Dual variable for uncertainty

    @constraint(model, sum(w) == 1)

    # Robust constraint: worst-case return >= target
    @constraint(model, dot(mu, w) - delta * sum(abs.(w)) >= target_return)

    @objective(model, Min, w' * Sigma * w)

    optimize!(model)
    return value.(w)
end
```

**Portfolio Backtesting**:
```julia
function backtest_strategy(allocation_func, returns, rf_rates)
    T, n = size(returns)
    wealth = ones(T)
    weights_history = zeros(T, n)

    for t in 2:T
        # Use data up to t-1 for allocation
        train_returns = returns[1:(t-1), :]

        # Compute allocation
        w = allocation_func(train_returns)
        weights_history[t, :] = w

        # Portfolio return at time t
        portfolio_return = dot(returns[t, :], w)
        wealth[t] = wealth[t-1] * (1 + portfolio_return)
    end

    return wealth, weights_history
end
```

**Performance Metrics**:
```julia
# Sharpe Ratio
sharpe_ratio = mean(portfolio_returns) / std(portfolio_returns) * sqrt(252)

# Maximum Drawdown
cumulative_returns = cumprod(1 .+ portfolio_returns)
running_max = cummax(cumulative_returns)
drawdowns = (cumulative_returns .- running_max) ./ running_max
max_drawdown = minimum(drawdowns)

# Turnover
turnover = mean(sum(abs.(weights[t, :] .- weights[t-1, :]) for t in 2:T))
```

**Outputs**:
- `data/allocation/julia/unfiltered_performance.csv`
- `data/allocation/julia/gaussian_performance.csv`
- `data/allocation/julia/student_t_performance.csv`
- `data/allocation/julia/all_scenarios_wealth.csv`
- `data/allocation/julia/summary_statistics.csv`

---

### Python Implementation: `support/dynamic_asset_allocation.py`

**Purpose**: Cross-validate Mean-Variance implementation

**Mean-Variance (scipy)**:
```python
import numpy as np
from scipy.optimize import minimize

def mean_variance_allocation(returns, target_return):
    n = returns.shape[1]
    mu = returns.mean(axis=0)
    Sigma = np.cov(returns, rowvar=False)

    # Objective: minimize variance
    def objective(w):
        return w @ Sigma @ w

    # Constraints
    constraints = [
        {'type': 'eq', 'fun': lambda w: np.sum(w) - 1},  # Fully invested
        {'type': 'ineq', 'fun': lambda w: w @ mu - target_return}  # Target return
    ]

    # Bounds: weights >= 0
    bounds = [(0, 1) for _ in range(n)]

    # Initial guess: equal weights
    w0 = np.ones(n) / n

    result = minimize(objective, w0, method='SLSQP',
                     bounds=bounds, constraints=constraints)

    return result.x
```

**Outputs**:
- `data/allocation/python/unfiltered_gamma1.0_performance.csv`
- `data/allocation/python/gaussian_gamma1.0_performance.csv`
- `data/allocation/python/student_t_gamma1.0_performance.csv`
- `data/allocation/python/summary_statistics.csv`

---

## Integration & Reporting

### Script: `reports/07_validation_report.Rmd`

**Purpose**: Synthesize results from all phases into final validation report

**Key Analyses**:
1. **SSM Parameter Comparison**: Gaussian vs. Student-t parameters
2. **Forecast Performance**: MAE, RMSE by scenario
3. **Allocation Performance**: Sharpe, Max Drawdown, Wealth by method and scenario
4. **Julia vs. Python Validation**: Numerical agreement check
5. **Filtering Effectiveness**: Does SSM improve allocation?

**Visualization**:
- Cumulative wealth trajectories
- Weight evolution over time
- Drawdown analysis
- Forecast error distributions

**Outputs**:
- `outputs/reports/07_validation_report.html`

---

## Data Directory Structure

```
data/
├── raw/                          # Downloaded data
│   ├── tsx_index_prices.csv
│   ├── tsx_index_returns.csv
│   └── tbill_rates.csv
│
├── filtered/                     # SSM filtered outputs
│   ├── gaussian_filtered_states.csv
│   ├── gaussian_params.csv
│   ├── student_t_filtered_states.csv
│   └── student_t_params.csv
│
└── allocation/                   # Portfolio allocation results
    ├── julia/
    │   ├── unfiltered_performance.csv
    │   ├── gaussian_performance.csv
    │   ├── student_t_performance.csv
    │   └── summary_statistics.csv
    │
    └── python/
        ├── unfiltered_gamma1.0_performance.csv
        ├── gaussian_gamma1.0_performance.csv
        ├── student_t_gamma1.0_performance.csv
        └── summary_statistics.csv
```

---

## Key Dependencies

### R Environment
```r
# Core packages
library(tidyverse)      # Data manipulation
library(tidyquant)      # Financial data download
library(KFAS)           # Kalman filter (Gaussian SSM)
library(pomp)           # Particle filter (Student-t SSM)

# Additional
library(forecast)       # Time series forecasting
library(lubridate)      # Date handling
```

### Julia Environment
```julia
using JuMP               # Optimization modeling
using Ipopt              # Nonlinear solver
using DataFrames         # Data structures
using CSV                # I/O
using Statistics         # Basic stats
using LinearAlgebra      # Matrix operations
```

### Python Environment
```python
import pandas as pd
import numpy as np
from scipy.optimize import minimize
from scipy import stats
import matplotlib.pyplot as plt
```

---

## Reproducibility Notes

### Random Seeds
- **Student-t SSM (pomp)**: Particle filter uses stochastic sampling
  - Set seed: `set.seed(42)` before running `pfilter()`
- **Julia allocation**: Deterministic (no randomness)
- **Python allocation**: Deterministic (no randomness)

### Numerical Precision
- **Convergence tolerance**: 1e-6 for all optimizers
- **Julia/Python agreement**: Results should match within 1e-4
- **Covariance estimation**: Use `cov(..., corrected=true)` for unbiased estimates

### Data Versioning
- **Download date**: Results depend on when data was downloaded (live API)
- **For exact replication**: Use provided CSVs in `data/raw/`

---

## Contact & Support

For questions about the methodology or implementation:
- Review the [Executive Summary](../docs/EXECUTIVE_SUMMARY.md) for high-level findings
- See the main [README.md](../README.md) for project overview

---

**API Documentation Version**: 1.0
**Last Updated**: January 2025
**Status**: Complete
