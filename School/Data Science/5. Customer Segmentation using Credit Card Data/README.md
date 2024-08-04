# Customer Segmentation Using Credit Card Data

## Overview

This project aims to segment credit card customers into distinct groups based on their transaction behaviors and balances. The dataset includes 8,950 rows and 18 columns, with the goal of identifying patterns and grouping customers for targeted marketing and personalized service.

## Data Description

- **Rows:** 8,950
- **Columns:** 18
  - **Customer ID:** Removed during data preparation
  - **Features:** Various numerical features related to credit card transactions and customer information

## Data Preparation

1. **Removed Customer ID:** The Customer ID column was removed as it does not contribute to the segmentation.
2. **Handling Missing Values:**
   - **Credit Limit:** Filled missing values with the mean of the column.
   - **Minimum Payment:** Filled missing values using backward fill.
3. **Feature Transformation:**
   - Applied log transformation to highly skewed numerical features to improve model performance and reduce skewness.

## Clustering Methods

1. **K-Means Clustering**
   - **Optimal Number of Clusters:** Determined to be 3 using the elbow method.
   - **Clusters Identified:**
     - **Target (Blue):** Higher balance and higher purchases.
     - **Sensible (Orange):** High balance but low purchases.
     - **Careless (Green):** Lower balance but high purchases.

2. **Hierarchical Clustering**
   - **Optimal Number of Clusters:** Determined to be 3 from the dendrogram using the longest distance.
   - **Clusters Identified:**
     - **Target (Green):** Higher balance and higher purchases.
     - **Sensible (Orange):** High balance but low purchases.
     - **Careless (Blue):** Lower balance but high purchases.

3. **DBSCAN**
   - **Cluster Identification:** DBSCAN automatically groups the data into clusters based on density.
   - **Performance:** DBSCAN can identify noise and outliers, demonstrating that K-Means and Hierarchical clustering may not handle noise effectively.

## Results and Analysis

- **K-Means and Hierarchical Clustering** both identified three similar clusters: Target, Sensible, and Careless, based on balance and purchases.
- **DBSCAN** was useful for detecting noise and outliers that K-Means and Hierarchical clustering did not handle well.
- Both K-Means and Hierarchical clustering methods performed effectively in customer segmentation, with similar results for the identified clusters.

## Installation

To run the models and analyses, ensure that the necessary libraries are installed. You can install them using pip:

```bash
pip install scikit-learn pandas matplotlib seaborn
