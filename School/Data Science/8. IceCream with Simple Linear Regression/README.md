# Ice Cream Revenue Forecasting

## Overview

This project aims to forecast daily revenue based on the outside temperature using regression analysis. The dataset contains 500 rows and 2 columns, providing historical data on temperature and corresponding revenue. The goal is to predict daily revenue (in USD) based on the outside temperature (°C).

## Data Description

- **Rows:** 500
- **Columns:** 2
  - **Temperature (°C):** Predictor attribute (X)
  - **Revenue (USD):** Target attribute (y)
- **Missing Values:** None

## Data Analysis

- **Correlation:** There is a strong positive correlation between temperature and revenue. As temperature increases, revenue tends to increase as well.
- **R² Score:** The model achieved an R² score of 0.98. This score indicates that the model explains 98% of the variance in the revenue data, which is very close to a perfect model.

## Results

- The results show minimal difference between the train, test, and actual datasets.
- The strong positive correlation between temperature and revenue was confirmed.
- The R² score of 0.98 suggests an excellent fit of the regression model to the data, indicating that the model accurately predicts daily revenue based on temperature.

## Installation

To use this model, ensure that the necessary libraries are installed. You can install them using pip:

```bash
pip install scikit-learn pandas
