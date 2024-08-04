# Association Rule Mining for Online Retail and Titanic Datasets

## Overview

This project applies the Apriori algorithm to uncover association rules from two datasets: an Online Retail dataset and the Titanic dataset. The goal is to identify frequent itemsets and association rules that can offer insights into customer behavior and passenger survival patterns.

## Datasets

### 1. Online Retail Dataset

- **Rows:** 541,909
- **Columns:** 8
- **Missing Values:** Found in 'Description' and 'CustomerID'
- **Duplicates:** 5,231 rows

#### Data Preparation

1. **Added 'TotalAmount':** Derived from 'Quantity' * 'UnitPrice'.
2. **Removed Negative Quantities:** Excluded 10,624 rows with negative 'Quantity'.
3. **Removed Duplicates:** 5,231 duplicated rows were removed.
4. **Removed Zero Prices:** Excluded 1,174 rows with 'UnitPrice' equal to 0.

#### Exploratory Data Analysis

- The most popular item is "paper craft, little birdie," with total sales of $168,459.60 and 80,995 units sold.
- The top revenue-generating countries are the United Kingdom, the Netherlands, EIRE, Germany, and France.
- The United Kingdom had the highest number of invoices, totaling 16,646.

#### Results

**United Kingdom Rules:**

- With a minimum support of 0.02, minimum confidence of 0.8, and minimum lift of 2, the rule indicates that customers who bought 'PINK REGENCY TEACUP AND SAUCER' and 'GREEN REGENCY TEACUP AND SAUCER' are 84.40% likely to also purchase 'ROSES REGENCY TEACUP AND SAUCER'.

**France Rules:**

- The itemset with 100% confidence is "SET/6 RED SPOTTY PAPER PLATES" and "SET/6 RED SPOTTY PAPER CUPS" with a minimum support of 0.02, minimum confidence of 0.8, and minimum lift of 2.

**EIRE Rules:**

- The most frequent itemset is "ROSES REGENCY TEACUP AND SAUCER," with 100% confidence and a minimum support of 0.02, minimum confidence of 0.8, and minimum lift of 2.

### 2. Titanic Dataset

- **Rows:** 891
- **Columns:** 12
- **Missing Values:** Found in 'Age,' 'Cabin,' and 'Embarked'
- **Duplicates:** None

#### Data Preparation

1. **Feature Selection:** Features such as 'age,' 'pclass,' 'survival,' and 'sex' were used.
2. **Column Renaming and Replacement:** Renamed 'survived' to 'survival', replaced binary survival values with 0 for 'Dead' and 1 for 'Survived'.
3. **Filled Missing Values:** 'Age' missing values were filled with 0.
4. **Binning Method:** The 'age' column was divided into categories: unknown, young, adult, and old.
5. **Transaction Encoding:** Converted records into a binary array or matrix with true or false values.

#### Exploratory Data Analysis

- The distribution shows that the majority of male passengers in PClass 3 did not survive.

#### Results

- With a minimum support of 0.02, the results indicate with 100% confidence that an individual who is old, deceased, and a member of PClass 1 is consistent with the dataset. Additionally, female survivors from PClass 1 who are adult-aged have a 96.55% confidence level. Death rates among men are high regardless of PClass.

## Installation

To run the models and analyses, ensure the necessary libraries are installed. You can install them using pip:

```bash
pip install pandas numpy scikit-learn mlxtend matplotlib seaborn
