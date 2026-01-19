# ML Factor Investing

Machine learning-driven factor investing research: predicting stock fundamentals and returns using 147 quantitative characteristics and SEC filing text features.

## Origin

This project originated from the **McGill-FIAM Asset Management Hackathon 2025**, where the challenge was to design and test an ML-driven investment strategy leveraging quantitative factors and text data from SEC filings to construct a profitable global equity long-short portfolio.

## Research Question

**Can machine learning predict stock returns?**

Our findings reveal a nuanced answer:
- **Direct return prediction**: R² ≈ 0 (confirms market efficiency literature)
- **Fundamental prediction**: R² = 0.43 (novel, actionable approach)
- **Direction classification**: AUC = 0.525 (weak but honest signal)

## Key Insight

Predicting accounting fundamentals (gross profit, operating cash flow) is significantly more tractable than predicting returns directly. This intermediate target approach offers a more stable and interpretable pathway to alpha generation.

## Methodology

### Data
- **Quantitative Features**: 147 stock characteristics from Jensen, Kelly, & Pedersen (2022)
- **Text Features**: SEC EDGAR filings (10-K, 10-Q) - Risk Factors & MD&A sections
- **Universe**: ~2,000 US securities, monthly frequency, 2005-2025
- **Panel Size**: 6.4M rows after filtering

### Machine Learning Pipeline
- **Model**: LightGBM (gradient boosting)
- **Hyperparameter Tuning**: Optuna-based optimization (100+ trials)
- **Cross-Validation**: Purged K-fold with embargo (prevents look-ahead bias)
- **Screening**: 6-stage universe construction (liquidity, size, volatility filters)

### Key Results

| Prediction Target | Metric | Value | Interpretation |
|-------------------|--------|-------|----------------|
| Excess Returns | R² | -0.008 | No predictive power |
| Up/Down Direction | AUC | 0.525 | Weak signal |
| Gross Profit/Assets | R² | **0.434** | Strong fundamental signal |
| Operating CF/Assets | R² | **0.411** | Strong fundamental signal |
| Operating Profit/Assets | R² | **0.381** | Good proxy for profitability |

## Project Structure

```
ml-factor-investing/
├── docs/
│   └── EXECUTIVE_SUMMARY.md      # Detailed findings and recommendations
├── src/
│   ├── data/                     # Data processing & screening
│   ├── models/                   # LightGBM tuning & training
│   ├── adapters/                 # Model adapters (LightGBM, penalized)
│   ├── portfolio/                # Portfolio construction
│   ├── analysis/                 # Large file analysis utilities
│   └── utils/                    # I/O and registry utilities
├── notebooks/
│   ├── 01_data_collection/       # Universe construction, SIC codes
│   ├── 02_eda_features/          # EDA, text exploration, feature engineering
│   ├── 03_modeling/              # Baseline, classification, regression, tuning
│   ├── 04_backtesting/           # Strategy backtesting
│   ├── 05_reports/               # Data quality reports
│   └── 06_advanced/              # End-to-end decision systems
├── outputs/
│   └── figures/                  # Visualizations
├── data/                         # Data directory (git-ignored)
├── references/                   # Academic papers
├── report/                       # Final hackathon deliverables (git-ignored)
└── tests/
```

## Notebooks Overview

| Stage | Notebooks | Purpose |
|-------|-----------|---------|
| **01_data_collection** | 3 | Investment universe, SIC codes, dataset merging |
| **02_eda_features** | 4 | Quantitative EDA, text exploration, exposures, feature engineering |
| **03_modeling** | 5 | Baseline pipeline, classification, regression tuning, accounting ratios |
| **04_backtesting** | 1 | Strategy backtesting framework |
| **05_reports** | 2 | Data quality dashboards |
| **06_advanced** | 1 | End-to-end PyTorch decision system |

## Technical Highlights

### Purged K-Fold with Embargo
Time-series cross-validation that prevents look-ahead bias:
- **Purge**: Removes observations within gap period before validation
- **Embargo**: Excludes observations after validation to reduce overfitting
- Implementation in `src/data/splitters.py`

### Sector-Neutral Screening
6-stage universe construction pipeline:
1. Liquidity filter (dollar volume, turnover)
2. Size filter (market cap percentile bands)
3. History filter (minimum observation count)
4. Data quality filter (missing value thresholds)
5. Volatility filter (idiosyncratic vol trimming)
6. Activity filter (recent trading check)

Implementation in `src/data/screening.py`

### Alpha Score Construction
13-factor composite score with sector-neutral z-scoring:
- **Long signals**: be_me, gp_at, op_at, ebit_sale, ni_be, sale_me, ocf_at, f_score, z_score, div12m_me
- **Short signals**: netdebt_me, beta_60m, ivol_ff3_21d

## Academic Foundation

This work builds on established research:
- Gu, Kelly, & Xiu (2020): *Empirical Asset Pricing via Machine Learning*
- Jensen, Kelly, & Pedersen (2022): Factor zoo (147 characteristics)
- Goyenko & Zhang (2022): Cross-validation methodology for financial ML

## Limitations

- **Backtest incomplete**: No Sharpe ratio or alpha metrics computed yet
- **Text features underutilized**: Only 0.1% coverage limits NLP contribution
- **Single market**: US equities only (hackathon scope)
- **No transaction costs**: Turnover not penalized in current implementation

## Requirements

See `requirements.txt` for Python dependencies. Key packages:
- `lightgbm` - Gradient boosting
- `optuna` - Hyperparameter optimization
- `pandas`, `polars` - Data manipulation
- `duckdb` - Large file streaming queries

## Status

**Research Phase**: Complete
**Backtesting**: Pending (deferred)
**Documentation**: In progress

---

*Part of the [quant-portfolio-research](../) collection.*
