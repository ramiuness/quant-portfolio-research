# Executive Summary: ML Factor Investing

## Study Overview

This research investigates machine learning approaches to stock return prediction using 147 quantitative characteristics and SEC filing text features. The work originated from the McGill-FIAM Asset Management Hackathon 2025.

**Key Finding**: Direct return prediction fails (R² ≈ 0), but fundamental prediction succeeds (R² = 0.43).

---

## Methodology

### Data Architecture
- **Panel**: ~2,000 US securities, monthly frequency, 2005-2025
- **Observations**: 6.4M rows (247K after filtering)
- **Quantitative Features**: 8 core predictors (shortlisted from 147 characteristics)
- **Text Features**: SEC EDGAR 10-K/10-Q filings (Risk Factors, MD&A)

### Feature Selection (Literature-Based)

The original 147 characteristics from Jensen, Kelly & Pedersen (2022) were shortlisted based on empirical predictive power from:
- Gu, Kelly & Xiu (2020) - Feature importance rankings
- Green, Hand & Zhang (2017) - 90 stock characteristics
- Goyenko & Zhang (2022) - OOS predictive rankings

**Shortlisting Pipeline**: 147 → 26 → 8 factors

| Stage | Source | Result |
|-------|--------|--------|
| Full universe | JKP (2022) | 147 factors |
| Literature shortlist | GKX + GHZ harvesting | 26 factors |
| Final predictive core | GZ (2022) empirical ranking | 8 factors |

**Final 8 Predictive Factors**:

| Factor | Category | Ranking | Source |
|--------|----------|---------|--------|
| `dolvol_126d` | Liquidity | High | Brennan, Chordia & Subrahmanyam (1998) |
| `turnover_126d` | Liquidity | High | Datar, Naik & Radcliffe (1998) |
| `market_equity` | Size | High | Banz (1981) |
| `rvol_21d` | Risk | High | GKX (2020) |
| `ni_ivol` | Risk | Medium | Ang et al. (2006) |
| `beta_60m` | Risk | Medium | Fama & MacBeth (1973) |
| `z_score` | Distress | Low | Dichev (1998) |
| `f_score` | Quality | Low | Piotroski (2000) |

**18 Factors Excluded** (from 26 shortlist):
- **Momentum family** (6): Weak post-2003, option signals dominate
- **Redundant liquidity** (4): Covered by turnover/dollar volume
- **Valuation ratios** (3): Weak OOS predictive power
- **Other** (5): Not robust in GKX/GZ testing

### Option Characteristics (Excluded)

Goyenko & Zhang (2022) documented 16 option-based predictors with **high predictive power**:

| Factor | Description | Ranking |
|--------|-------------|---------|
| `opt_baspread` | Option bid-ask spread | **High** |
| `os` | Option-to-stock volume ratio | **High** |
| `skewness` | Volatility skew (smirk) | **High** |
| `hviv` | Historical vol - Implied vol spread | Medium |
| `cvol`, `pvol` | Change in call/put IV | Medium |

**Exclusion Reason**: Lack of access to OptionMetrics and WRDS databases. The literature suggests option factors dominate stock factors post-2003, making this a significant limitation.

### Machine Learning Pipeline
- **Model**: LightGBM gradient boosting
- **Tuning**: Optuna with 100+ trials
- **CV Strategy**: Purged K-fold with embargo (5 folds)
- **Screening**: 6-stage universe construction

---

## Key Results

### Task 1: Direct Return Prediction (Regression)

| Metric | Value | Interpretation |
|--------|-------|----------------|
| R² | -0.008 | No predictive power |
| RMSE | 0.081 | High error relative to signal |
| MAE | 0.081 | Large absolute errors |

**Conclusion**: Confirms market efficiency literature. Direct return prediction is intractable with standard ML approaches.

### Task 2: Direction Classification (Up/Down)

| Metric | Value | Interpretation |
|--------|-------|----------------|
| Accuracy | 54% | Modest, above random (50%) |
| AUC | 0.525 | Weak discriminative power |
| F1 | 0.685 | Balanced precision/recall |
| Precision | 0.542 | Moderate selectivity |
| Recall | 0.935 | High true positive rate |

**Conclusion**: Weak signal with asymmetric prediction bias. Limited practical value for trading.

### Task 3: Fundamental Prediction (Novel Approach)

| Target | R² | Interpretation |
|--------|-----|----------------|
| **Gross Profit / Assets** | **0.434** | Best predictor |
| **Operating CF / Assets** | **0.411** | Strong signal |
| **Operating Profit / Assets** | **0.381** | Good profitability proxy |
| Book-to-Market | 0.301 | Reasonable |
| Net Income Quality | 0.250 | Moderate |
| Sales-to-Market | 0.268 | Moderate |
| Net Debt-to-Market | 0.208 | Weak-to-moderate |
| Net Income-to-Market | 0.137 | Weak |

**Conclusion**: Predicting fundamentals is significantly more tractable than predicting returns directly. This offers a pathway to alpha via intermediate targets.

---

## Strategic Insights

### What Works
1. **Fundamental factor prediction** (R² up to 0.43) is more tractable than return prediction
2. **Sector-neutral screening** meaningfully reduces noise
3. **Time-series CV with purge/embargo** prevents look-ahead bias
4. **LightGBM with gradient boosting** captures non-linear relationships

### What Doesn't Work
1. **Direct return prediction** (R² ~0) — confirms market efficiency
2. **Text features** sparse coverage (0.1%) limits contribution
3. **Classification direction** weak (AUC 0.525) — minimal practical value

---

## Feature Importance

### Top Quantitative Predictors
Based on LightGBM feature importance across experiments:

| Rank | Feature | Category | Description |
|------|---------|----------|-------------|
| 1 | `gp_at` | Profitability | Gross profit / Total assets |
| 2 | `op_at` | Profitability | Operating profit / Total assets |
| 3 | `ocf_at` | Cash Flow | Operating cash flow / Total assets |
| 4 | `be_me` | Value | Book equity / Market equity |
| 5 | `sale_me` | Value | Sales / Market equity |
| 6 | `ni_be` | Profitability | Net income / Book equity |
| 7 | `ebit_sale` | Profitability | EBIT / Sales |
| 8 | `beta_60m` | Risk | 60-month market beta |
| 9 | `ivol_ff3_21d` | Risk | Idiosyncratic volatility |
| 10 | `netdebt_me` | Leverage | Net debt / Market equity |

### Text Features (Limited Coverage)
- Risk Factor word counts: 6.8K observations with data
- MD&A word counts: Sparse coverage
- **Limitation**: Only 0.1% of rows have both RF and MD&A features

---

## Screening Pipeline

### 6-Stage Universe Construction

| Stage | Filter | Threshold | Purpose |
|-------|--------|-----------|---------|
| 1 | Liquidity | Dollar volume ≥ $2M, turnover ≥ 0.001 | Tradability |
| 2 | Size | Market cap 20th-95th percentile (sector-relative) | Avoid microcaps |
| 3 | History | ≥36 months continuous data | Statistical stability |
| 4 | Data Quality | No missing values for key features | Model requirements |
| 5 | Volatility | Exclude top 10% most volatile (sector-relative) | Risk control |
| 6 | Activity | Recent trading in last 3 months | Current viability |

**Result**: ~947 stocks from ~2,000 universe

---

## Cross-Validation Strategy

### Purged K-Fold with Embargo

```
Timeline:  ────────────────────────────────────────────►
           │ Train │ Purge │ Valid │ Embargo │ Train │

Purge:   2 months before validation (removes leakage)
Embargo: 2 months after validation (reduces overfitting)
Folds:   5 contiguous time blocks
```

**Implementation**: `src/data/splitters.py`

---

## Limitations

### Data Constraints
- **No option data**: OptionMetrics and WRDS access unavailable; option factors (which dominate post-2003 per GZ 2022) excluded
- **Single market**: US equities only
- **Text coverage**: Only 0.1% of rows have complete text features
- **No transaction costs**: Turnover not penalized

### Methodology Constraints
- **Backtest incomplete**: No Sharpe/alpha metrics yet
- **No out-of-sample validation**: Only CV metrics reported
- **Standard ML only**: No neural networks or advanced architectures

### Scope Constraints
- **Hackathon timeline**: Limited experimentation depth
- **No live trading**: Paper analysis only

---

## Recommendations

### For Practitioners
1. **Use fundamental prediction** as intermediate target, not direct returns
2. **Implement sector-neutral operations** to reduce systematic biases
3. **Apply purged CV** rigorously to avoid overfitting in financial data

### For Future Work
1. Complete backtesting with Sharpe ratio and alpha metrics
2. **Acquire option data** (OptionMetrics/WRDS) to include high-ranking option factors
3. Expand text feature coverage via alternative NLP pipelines
4. Test neural network architectures (transformers, LSTMs)
5. Add transaction cost modeling

---

## Technical Validation

| Component | Status | Notes |
|-----------|--------|-------|
| Data pipeline | Complete | 6.4M → 247K rows after filtering |
| Feature engineering | Complete | 147 quantitative + text features |
| Model training | Complete | LightGBM with Optuna tuning |
| Cross-validation | Complete | Purged K-fold with embargo |
| Backtesting | **Pending** | Deferred to future work |
| Documentation | Complete | README, notebooks documented |

---

## Conclusion

This study demonstrates that while direct stock return prediction remains intractable (R² ≈ 0), predicting accounting fundamentals offers a viable alternative (R² = 0.43). The sector-neutral screening pipeline and purged cross-validation methodology provide a rigorous foundation for factor-based investing research.

**Bottom Line**: Focus on what ML *can* predict (fundamentals) rather than what it *can't* (returns directly).

---

**Project**: ML Factor Investing
**Origin**: McGill-FIAM Asset Management Hackathon 2025
**Status**: Research complete, backtesting pending
