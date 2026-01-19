# Source Code Documentation

## Module Overview

```
src/
├── data/           # Data processing and screening
├── models/         # Model training and tuning
├── adapters/       # Model interface adapters
├── portfolio/      # Portfolio construction
├── analysis/       # Large file analysis utilities
└── utils/          # I/O and registry utilities
```

---

## data/

### `prep.py`
Data preparation utilities for ML pipeline.

**Functions**:
- `prepare_panel()` - Main preprocessing orchestrator
- `winsorize()` - Outlier trimming at specified percentiles
- `scale_features()` - Feature scaling (rank, z-score, quantile normal)
- `impute_missing()` - Missing value imputation strategies

### `splitters.py`
Time-series cross-validation strategies.

**Functions**:
- `expanding_windows()` - Outer expanding window CV with purge/embargo
- `inner_folds()` - Inner purged K-fold within training slice

**Parameters**:
- `train_years_start` - Start of training window
- `val_years` - Validation period length
- `test_years` - Test period length
- `step_months` - Step size between windows
- `purge_horizon` - Gap before validation (prevents leakage)
- `embargo` - Gap after validation (reduces overfitting)

### `screening.py`
Universe screening and alpha score construction.

**Functions**:
- `screen_liquidity()` - Dollar volume and turnover filters
- `screen_mcap_band()` - Sector-relative size percentile banding
- `screen_history()` - Minimum observation count per ticker
- `screen_volatility()` - Idiosyncratic volatility trimming
- `screen_active_recent()` - Rolling activity check
- `sector_neutral_zscores()` - Date-sector-relative standardization
- `build_alpha_score()` - 13-factor composite alpha construction
- `mark_long_short()` - Decile marking per (date, sector)
- `pick_top_per_sector()` - Top-K selection
- `cap_subsector_share()` - Subsector concentration limits
- `build_universe()` - Full screening orchestrator

### `lead_ratios.py`
Accounting feature engineering.

**Functions**:
- `compute_lead_ratios()` - Forward-looking ratio computation

---

## models/

### `tuning.py`
LightGBM hyperparameter tuning with Optuna.

**Classes**:
- `FoldResult` - Dataclass for classification fold metrics
- `FoldResultReg` - Dataclass for regression fold metrics
- `TrialResult` - Aggregated trial results

**Functions**:
- `tune_lightgbm_classifier()` - 3-phase classifier tuning
- `tune_lightgbm_regressor()` - 3-phase regressor tuning
- `evaluate_params_over_timecv()` - CV evaluation wrapper
- `_threshold_sweep()` - Optimal threshold selection
- `_topk_metrics()` - Top-K precision metrics

**Tuning Phases**:
1. Coarse search (broad parameter ranges)
2. Refinement (narrow around best)
3. Final assembly (ensemble or refit)

### `run_modeling.py`
Model training orchestration.

**Functions**:
- `run_experiment()` - End-to-end experiment runner
- `load_and_prepare()` - Data loading and preparation
- `train_model()` - Model fitting with selected parameters

---

## adapters/

### `lightgbm.py`
LightGBM model adapter with unified interface.

**Classes**:
- `LightGBMAdapter` - Wrapper for LightGBM with grid search
- `Bundle` - Dataclass (model, centering, info)

**Methods**:
- `fit_select()` - Parameter grid search via CV
- `predict()` - Generate predictions
- `feature_importance()` - Extract importance scores

### `penalized.py`
Penalized linear model adapter (Ridge, Lasso, ElasticNet).

**Classes**:
- `PenalizedAdapter` - Unified interface for sklearn penalized models

**Methods**:
- `fit_select()` - Alpha grid search
- `predict()` - Generate predictions

---

## portfolio/

### `portfolio_analysis.py`
Portfolio construction and performance analysis.

**Functions**:
- `construct_portfolio()` - Build long-short portfolio from signals
- `compute_returns()` - Calculate portfolio returns
- `performance_metrics()` - Sharpe, Sortino, max drawdown

---

## analysis/

### `large_file_query.py`
DuckDB-based streaming analysis for large files.

**Classes**:
- `LargeFileAnalyzer` - Memory-safe large file operations

**Methods**:
- `setup_views()` - Create DuckDB views for parquet/CSV
- `get_schema_info()` - Schema introspection without materialization
- `get_unique_identifiers()` - Cross-source identifier counts
- `compute_word_counts()` - Streaming text feature extraction
- `generate_summary_stats()` - SQL-based aggregations

---

## utils/

### `io_utils.py`
I/O utilities for data loading and saving.

**Functions**:
- `load_config()` - Load JSON configuration
- `load_panel()` - Load panel data from CSV/parquet
- `save_preds()` - Save predictions to file
- `save_metrics()` - Save performance metrics

### `registry.py`
Model registry factory pattern.

**Functions**:
- `get_model()` - Factory function for model instantiation
- `register_model()` - Register custom model adapters

---

## Usage Example

```python
from src.data.prep import prepare_panel
from src.data.splitters import expanding_windows
from src.data.screening import build_universe
from src.models.tuning import tune_lightgbm_classifier
from src.adapters.lightgbm import LightGBMAdapter

# 1. Load and prepare data
panel = prepare_panel(raw_data, winsorize_pct=0.01)

# 2. Screen universe
universe = build_universe(panel, min_history=36, liquidity_threshold=2e6)

# 3. Generate CV splits
splits = list(expanding_windows(
    universe,
    train_years_start=2010,
    val_years=1,
    purge_horizon=2,
    embargo=2
))

# 4. Tune model
best_params = tune_lightgbm_classifier(
    X_train, y_train,
    cv_splits=splits,
    n_trials=100
)

# 5. Train final model
adapter = LightGBMAdapter(best_params)
adapter.fit(X_train, y_train)
predictions = adapter.predict(X_test)
```
