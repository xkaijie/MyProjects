# Movie Recommendation System - TMDB 5000 Dataset

## 1. Introduction

The TMDB 5000 dataset is a comprehensive movie metadata dataset containing information about thousands of movies, including their titles, genres, release dates, ratings, and other attributes. This project aims to create a movie recommendation system that suggests movies based on their textual descriptions. The goal is to enhance user experience by recommending movies that align with their interests and preferences, thus increasing engagement with the recommended movies.

## 1.1 Details of Approach

### Content-Based Filtering

Content-based filtering is a recommendation technique that focuses on the characteristics of items to make recommendations. This approach analyzes features and attributes of items, such as text, metadata, or user-generated content, to understand their properties and match them to user preferences.

### 1.2 Algorithms

The overall solution approach is summarized as follows:

1. **Data Understanding**
2. **Exploratory Data Analysis (EDA)**
3. **Data Preprocessing**
4. **Feature Engineering**
5. **Recommendation System Implementation**

## 1.3 Experimental Results and Analysis

### 1.3.1 Experimental Setup

#### Data Understanding

- **Dataset**: TMDB 5000 Movie dataset
- **Rows and Columns**: 4803 rows and 23 columns
- **Data Types**: 16 strings, 4 integers, 3 floats
- **Missing Values**: Homepage, Overview, Release Date, Runtime, Tagline

#### EDA

- **Missing Values**:
  - Homepage: 3091
  - Overview: 3
  - Release Date: 1
  - Runtime: 2
  - Tagline: 124

- **Top Production Companies**:
  - Warner Bros, Universal Pictures, Paramount Pictures produce the most movies.

- **Top Genres**:
  - Comedy, Drama, Thriller, Romance

- **Top Popular Movies**:
  - Predominantly movies produced after the year 2000

### 2. Data Preprocessing

- **Data Cleansing**:
  - Checked for duplicated rows
  - Handled missing values using `dropna()` for columns with missing values
  - Replaced square brackets with empty strings
  - Split text in the overview column
  - Removed spaces between words for genres, keywords, cast, and crew features

- **Feature Engineering**:
  - Derived `tags` feature from overview, genres, keywords, cast, and crew
  - Created a new data frame (`movies2`) consisting only of `id`, `original_title`, and `tags` for recommendation purposes

#### Sample of First 5 Rows After Data Preprocessing

| id | original_title | tags                           |
|----|----------------|--------------------------------|
| 1  | Movie Title 1  | adventure, drama, action        |
| 2  | Movie Title 2  | romance, drama, fantasy         |
| 3  | Movie Title 3  | comedy, action, thriller        |
| 4  | Movie Title 4  | drama, thriller, crime          |
| 5  | Movie Title 5  | sci-fi, action, adventure       |

## 4. Feature Engineering

- **New Feature `tags`**:
  - Derived from overview, genres, keywords, cast, and crew

- **Text Vectorization**:
  - Used `CountVectorizer` to convert text documents into a matrix of word counts

- **Text Processing**:
  - Applied `PorterStemmer` to reduce words to their root form, improving text analysis by grouping similar words

## 5. Recommendation System – Content-Based Filtering

### Steps for Recommendations

1. **Text Vectorization**:
   - Applied `CountVectorizer` to the `tags` column of the `movies2` dataframe to convert it into a feature matrix of token counts.

2. **Text Processing**:
   - Used `PorterStemmer` to stem the words in the `tags` column to enhance feature quality.

3. **Similarity Measurement**:
   - Used `cosine_similarity` from `sklearn.metrics.pairwise` to calculate pairwise cosine similarity between feature vectors of movies.

4. **Recommendation Function**:
   - The `recommend_me` function takes a movie name as input, finds its index in the `movies2` dataframe, calculates the cosine similarity between this movie and all other movies, and returns the top 5 most similar movies as recommendations.

### Example Usage

```python
from sklearn.metrics.pairwise import cosine_similarity
import pandas as pd

# Load data
movies2 = pd.read_csv('movies2.csv')

# Function to get movie recommendations
def recommend_me(movie_name):
    movie_idx = movies2[movies2['original_title'] == movie_name].index[0]
    similarity_scores = cosine_similarity(matrix[movie_idx], matrix)
    similar_movies = list(enumerate(similarity_scores[0]))
    sorted_movies = sorted(similar_movies, key=lambda x: x[1], reverse=True)
    top_movies = [movies2['original_title'][i[0]] for i in sorted_movies[1:6]]
    return top_movies

# Get recommendations for 'Movie Title 1'
print(recommend_me('Movie Title 1'))
