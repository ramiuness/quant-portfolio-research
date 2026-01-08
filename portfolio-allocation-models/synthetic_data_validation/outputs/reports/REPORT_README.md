# Report Generation Guide

This directory contains the analysis reports for the Portfolio Optimization Models validation study.

---

## 📄 Available Reports

### 1. Jupyter Notebook (Source)
**File**: `Phase1_Synthetic_Validation_Complete.ipynb`

- Full reproducible analysis with source code
- All computations and visualizations
- Can be run interactively in Jupyter
- Best for: Technical review, reproduction, modification

**How to open**:
```bash
jupyter notebook Phase1_Synthetic_Validation_Complete.ipynb
```

---

### 2. HTML Report (Presentation)
**File**: `Phase1_Synthetic_Validation_Complete.html`

- Clean, professional presentation
- Code hidden by default for readability
- All visualizations and findings included
- Best for: Sharing, presentations, stakeholders

**How to view**:
- Double-click the HTML file, or
- Open in any web browser
- (File will be generated - see instructions below)

---

## 🔨 Generating HTML Reports

### Method 1: Clean HTML (Code Hidden) - Recommended

This generates a professional HTML report with all code cells hidden:

```bash
jupyter nbconvert --to html --no-input Phase1_Synthetic_Validation_Complete.ipynb
```

**Output**: `Phase1_Synthetic_Validation_Complete.html` (code hidden)

---

### Method 2: Full HTML (Code Visible)

This generates HTML with code cells visible:

```bash
jupyter nbconvert --to html Phase1_Synthetic_Validation_Complete.ipynb
```

**Output**: `Phase1_Synthetic_Validation_Complete.html` (code visible)

---

### Method 3: Custom Template (Advanced)

For more control over the output, use a custom template:

```bash
jupyter nbconvert --to html --template classic Phase1_Synthetic_Validation_Complete.ipynb
```

Available templates:
- `classic` - Traditional notebook style
- `lab` - JupyterLab style
- `basic` - Minimal styling

---

## 🔧 Setup & Dependencies

### Prerequisites

#### Julia 1.6+
```bash
# Check Julia version
julia --version
```

#### Required Julia Packages
```julia
using Pkg

# Core packages
Pkg.add("DataFrames")
Pkg.add("CSV")
Pkg.add("Statistics")
Pkg.add("LinearAlgebra")
Pkg.add("Distributions")
Pkg.add("Random")

# Visualization
Pkg.add("Plots")
Pkg.add("PrettyTables")

# Optimization
Pkg.add("JuMP")
Pkg.add("Ipopt")
```

#### Jupyter Notebook
```bash
# Install Jupyter (if not already installed)
pip install jupyter

# Install IJulia kernel for Julia
julia -e 'using Pkg; Pkg.add("IJulia")'
```

---

## 📊 Running the Analysis

### Step 1: Navigate to Project Directory
```bash
cd /path/to/synthetic_data_validation/
```

### Step 2: Start Jupyter
```bash
jupyter notebook
```

### Step 3: Open the Notebook
- Navigate to `outputs/reports/Phase1_Synthetic_Validation_Complete.ipynb`
- Click to open

### Step 4: Run All Cells
- **Kernel** → **Restart & Run All**
- Or run cells individually with `Shift + Enter`

### Expected Runtime
- Full analysis: ~2-5 minutes (depending on system)
- Individual models: ~10-30 seconds each

---

## 📁 Output Files Generated

When you run the notebook, the following files are created/updated:

### Data Files (`../data/`)
- `metrics_5models.csv` - Comprehensive metrics for all models
- `validation_summary_5models.csv` - Validation status table

### Figures (`../figures/`)
- `theme1_performance_metrics.png` - Performance comparison
- `theme2_diversification_capacity.png` - Capacity analysis
- `theme3_classical_vs_robust.png` - MV family comparison
- `theme4_risk_return_tradeoffs.png` - Risk-return scatter
- `weight_heatmap.png` - Portfolio weight distributions

---

## 🐛 Troubleshooting

### Issue: "Package not found"
```julia
# Install missing packages
using Pkg
Pkg.add("PackageName")
```

### Issue: "IJulia kernel not found"
```bash
# Reinstall IJulia
julia -e 'using Pkg; Pkg.add("IJulia"); Pkg.build("IJulia")'
```

### Issue: "File path not found"
- Check that you're running from the correct directory
- Verify paths in include statements are relative to notebook location
- The notebook expects to be in `outputs/reports/`

### Issue: "nbconvert not found"
```bash
# Install nbconvert
pip install nbconvert

# Or with conda
conda install nbconvert
```

### Issue: HTML export fails
```bash
# Install pandoc (required for nbconvert)
# On Ubuntu/Debian:
sudo apt-get install pandoc

# On macOS:
brew install pandoc

# On Windows:
# Download from https://pandoc.org/installing.html
```

---

## 📖 Understanding the Report Structure

### Part A: Setup & Validation
1. **Data Generation**: Synthetic returns from multivariate lognormal
2. **Model Execution**: All 5 models with adaptive optimization
3. **Validation Summary**: Technical correctness verification

### Part B: Comparative Analysis
1. **Theme 1 - Performance**: Risk-adjusted returns (Sharpe, IR, Sortino)
2. **Theme 2 - Diversification**: Capacity and concentration metrics
3. **Theme 3 - Classical vs Robust**: MV family comparison
4. **Theme 4 - Risk-Return**: Trade-offs and efficiency

### Summary & Conclusions
- Key takeaways from all themes
- Strategic implications
- Technical innovations
- Next steps (Phase B)

---

## 🎨 Customizing Visualizations

To modify figure sizes or styles, edit the visualization functions in:
```
../../src/visualize_themes.jl
```

To save figures automatically, set `save_fig=true` in theme functions:
```julia
theme1_performance_metrics(metrics_df, save_fig=true)
```

Figures are saved to: `../figures/`

---

## 📧 Sharing the Report

### For Technical Audiences
- Share the `.ipynb` file
- Recipients can run it themselves to verify results
- Include this README for setup instructions

### For Non-Technical Audiences
- Generate HTML with code hidden (`--no-input`)
- Share the `.html` file
- Can be opened in any browser, no software required

### For Presentations
- Extract figures from `../figures/` directory
- Use Executive Summary for talking points
- Reference full HTML report for details

---

## 🔗 Related Documentation

- **Executive Summary**: [../../docs/EXECUTIVE_SUMMARY.md](../../docs/EXECUTIVE_SUMMARY.md)
- **Project README**: [../../README.md](../../README.md)
- **Adaptive Targets**: [../../docs/ADAPTIVE_TARGETS_README.md](../../docs/ADAPTIVE_TARGETS_README.md)
- **Notebook Guide**: [../../docs/NOTEBOOK_GUIDE.md](../../docs/NOTEBOOK_GUIDE.md)

---

## 📝 Version Information

- **Report Version**: Phase 1 - Synthetic Data Validation
- **Models Included**: 5 (MV, CVaR, Omega, MVBU, MVEU)
- **Status**: Phase A Complete | Phase B Pending (GMM-based models)
- **Last Updated**: January 2025

---

## ⚙️ Advanced Options

### Export to PDF

Requires LaTeX installation:

```bash
jupyter nbconvert --to pdf Phase1_Synthetic_Validation_Complete.ipynb
```

### Export to Markdown

```bash
jupyter nbconvert --to markdown Phase1_Synthetic_Validation_Complete.ipynb
```

### Extract Code Only

```bash
jupyter nbconvert --to script Phase1_Synthetic_Validation_Complete.ipynb
```

Output: `Phase1_Synthetic_Validation_Complete.jl`

---

## 📞 Support

For issues with:
- **Notebook content**: Review the code cells and comments
- **Julia packages**: Check Julia documentation
- **Jupyter/nbconvert**: Check Jupyter documentation
- **Project-specific questions**: See main project README

---

**Happy analyzing! 📊**
