#!/bin/bash
# Deploy HTML report to GitHub Pages

# Create a temporary directory for gh-pages
mkdir -p /tmp/gh-pages-model-validation
cd /tmp/gh-pages-model-validation

# Copy the HTML file
cp /home/ramiuness/Documents/job/demos/model-validation/portfolio-allocation-models/synthetic_data_validation/outputs/reports/Phase1_Synthetic_Validation_Complete.html index.html

# Initialize git and create gh-pages branch
git init
git checkout -b gh-pages
git add index.html
git commit -m "Deploy portfolio optimization validation report"

# Push to GitHub (you'll need to add remote)
echo ""
echo "To complete deployment, run:"
echo "cd /tmp/gh-pages-model-validation"
echo "git remote add origin https://github.com/ramiuness/model-validation.git"
echo "git push -f origin gh-pages"
echo ""
echo "Then enable GitHub Pages in repo settings (Settings > Pages > Source: gh-pages branch)"
echo "Your report will be at: https://ramiuness.github.io/model-validation/"
