#pip install pandas psycopg2-binary SQLAlchemy

import pandas as pd

file_path = 'GraduateEmploymentSurveyNTUNUSSITSMUSUSSSUTD.csv'
df = pd.read_csv(file_path)
print(df)

from sqlalchemy import create_engine

# Database connection details
db_username = 'postgres'
db_password = 'admin'
db_host = 'localhost'
db_port = '5432'
db_name = 'postgres'

# SQLAlchemy engine for PostgreSQL
engine = create_engine(f'postgresql://{db_username}:{db_password}@{db_host}:{db_port}/{db_name}')

# Test the connection
try:
    with engine.connect() as connection:
        print("Database connection successful.")
        # You can add more code here to interact with the database

except Exception as e:  # This catches any exception that might occur
    print(f"An error occurred: {e}")

finally:
    print("This block executes no matter what")