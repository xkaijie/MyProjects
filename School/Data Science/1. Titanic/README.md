# Titanic Dataset Analysis

## Introduction

The Titanic dataset contains information on passengers aboard the Titanic, including demographics, cabin class, and survival status. The primary objective of this project is to predict whether a passenger survived or not based on these features. This is a binary classification problem, offering an opportunity to explore various machine learning techniques for class imbalance and feature engineering.

## Approach

### 1. Supervised Learning

Since the target variable is binary (survived: 0 or 1), we will apply and optimize the following classification models:

- **Logistic Regression**
- **Support Vector Classification with RBF Kernel (SVC-RBF)**
- **Random Forest Classifier (RFC)**
- **Convolutional Neural Network (CNN)** (for experimentation)

### 2. Unsupervised Learning

Clustering will be used to uncover segments related to survival:

- **Mean Shift Clustering**
- **K-Means Clustering**

### 3. Experimental Results and Analysis

#### 1. Data Understanding

- **Dataset**: 891 rows, 12 columns
- **Features**: Age, Sex, Pclass, Cabin, Embarked, etc.
- **Missing Values**: Age, Cabin, Embarked

#### 2. Data Preprocessing

- **Data Cleansing**:
  - Filled missing Age values with median age per class.
  - Replaced missing Fare with median fare per class.
  - Filled missing Embarked values with mode.
  - Replaced missing Cabin values with 'unknown'.

- **Feature Engineering**:
  - Encoded `Sex` feature (male = 1, female = 0).
  - Created `familySize` from `SibSp` and `Parch`.
  - Created `isalone` feature based on `familySize`.

- **Normalization**: Applied to ensure uniform feature scaling.

#### 3. Modelling

- **Supervised Learning**:
  - Logistic Regression
  - SVC-RBF
  - Random Forest Classifier
  - CNN (with optimizer='adam', loss='binary_crossentropy', metric='accuracy')

- **Unsupervised Learning**:
  - **Mean Shift Clustering**: Effective for low-dimensional data.
  - **K-Means Clustering**: Optimal number of clusters determined by elbow plot.

#### 4. Evaluation

- **Classification Metrics**:
  - **Logistic Regression**: Accuracy (Train/Test): 0.79 / 0.82
  - **SVC-RBF**: Accuracy (Train/Test): 0.82 / 0.85
  - **Random Forest Classifier**: Accuracy (Train/Test): 0.90 / 0.80
  - **CNN**: Accuracy (Train/Test): 0.83 / 0.80

- **ROC AUC Scores**:
  - **Logistic Regression**: 0.80
  - **SVC-RBF**: 0.84
  - **RFC**: 0.78
  - **CNN**: 0.89

- **Feature Importance**:
  - **Logistic Regression & SVC-RBF**: Sex > FamilySize > Age > Isalone > Fare
  - **RFC**: Fare > Sex > Age > FamilySize > Isalone

### 5. Results and Insights

- Passengers with higher fares and family sizes showed increased survival rates.
- Female passengers had a higher chance of survival compared to males.
- The clustering results provided insights into different survival segments.

## Installation

To run this project, ensure you have the following Python libraries installed:

```bash
pip install numpy pandas scikit-learn matplotlib seaborn tensorflow
