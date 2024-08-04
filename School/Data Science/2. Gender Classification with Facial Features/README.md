# Gender Classification Model

## Overview

This project aims to classify gender based on facial feature measurements using various machine learning models. The dataset consists of 5001 rows with 8 columns, where 7 columns are numerical and 1 column is categorical. The goal is to predict the gender of individuals using the facial feature data.

## Data Description

- **Rows:** 5001
- **Columns:** 8
  - **Numerical Columns:** 7
  - **Categorical Column:** 1 (gender)
- **Missing Values:** None
- **Duplicates:** 1,768 duplicated rows (removed during data preparation)

## Data Preparation

1. **Removed Duplicates:** 1,768 duplicated rows were removed.
2. **Label Encoding:** The `gender` column was transformed into binary values (0 and 1).
3. **Feature Scaling:** The predictor attributes were scaled to a range of 0 to 1 using MinMax Scaler.
4. **Data Splitting:** The dataset was split into training and testing sets with a 70:30 ratio.

## Models Evaluated

1. **Logistic Regression**
   - **Accuracy:** 95.57%
   - **Execution Time:** 0.106 seconds

2. **Decision Tree Classifier**
   - **Accuracy:** 95.15%
   - **Execution Time:** 0.053 seconds

3. **Random Forest Classifier**
   - **Accuracy:** 94.85%

4. **Support Vector Classifier (SVC) Linear**
   - **Accuracy:** 94.33%

## Results

- The Logistic Regression model achieved the highest accuracy score of 95.57%.
- The Decision Tree Classifier followed with an accuracy of 95.15%.
- The Random Forest Classifier and SVC Linear had slightly lower accuracy scores of 94.85% and 94.33%, respectively.
- Despite the Logistic Regression model having a slightly longer execution time compared to the Decision Tree, it is recommended due to its superior overall accuracy, precision, and recall scores.

## Recommendation

Based on the performance metrics, Logistic Regression is recommended as the best model for gender classification due to its high accuracy, precision, and recall.

## Installation

To use this model, ensure that the necessary libraries are installed. You can install them using pip:

```bash
pip install scikit-learn pandas
