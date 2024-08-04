# Weather Prediction Model

## Overview

This project aims to predict whether it will rain the next day based on weather data using various machine learning models. The dataset comprises 145,460 rows and 23 columns. The goal is to forecast rain occurrence using historical weather features.

## Data Description

- **Rows:** 145,460
- **Columns:** 23
  - **Categorical Features:** Several columns with missing values, filled with the mode of each column.
  - **Numerical Features:** Several columns with missing values, filled with the mean of each column.
- **Date Column:** Derived into `Year`, `Month`, and `Day` columns; the original `Date` column was removed.
- **Missing Values:** Handled by filling categorical features with mode and numerical features with mean.

## Data Preparation

1. **Feature Separation:** Separated the columns into categorical and numerical features.
2. **Missing Values Handling:**
   - Categorical features: Filled with the mode of each column.
   - Numerical features: Filled with the mean of each column.
3. **Date Processing:** Extracted `Year`, `Month`, and `Day` from the `Date` column; removed the original `Date` column.
4. **Label Encoding:** Converted categorical feature values to numeric values using Label Encoder.
5. **Feature Scaling:** Used Standard Scaler to transform predictor attributes to a range of 0 to 1.

## Models Evaluated

1. **Random Forest Classifier**
   - **Accuracy:** 85.49%
   - **Precision and Recall:** Highest precision and recall, but recall for predicting rainy days is 0.50 (50%).

2. **Logistic Regression**
   - **Accuracy:** 84.23%

3. **Support Vector Classifier (SVC) Linear**
   - **Accuracy:** 84.17%

4. **Decision Tree Classifier**
   - **Accuracy:** 83.78%

## Results

- The Random Forest Classifier achieved the highest accuracy score of 85.49%.
- Logistic Regression followed with an accuracy score of 84.23%.
- SVC Linear scored 84.17%, and the Decision Tree Classifier had the lowest accuracy of 83.78%.
- Despite its high accuracy, the Random Forest model's recall score for predicting rainy days is 0.50, indicating it correctly predicted 50% of the rainy days.

## Recommendation

The Random Forest Classifier is recommended as the best model due to its highest accuracy. However, it is important to note that its recall score for predicting rainy days is only 50%, which may be a consideration depending on the application's tolerance for false negatives.

## Installation

To use this model, ensure that the necessary libraries are installed. You can install them using pip:

```bash
pip install scikit-learn pandas
