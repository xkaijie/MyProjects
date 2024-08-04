# Create Table (PGAdmin)
CREATE TABLE graduate_employment (
    year INT,
    university TEXT,
    school TEXT,
    degree TEXT,
    employment_rate_overall NUMERIC(5, 2),
    employment_rate_ft_perm NUMERIC(5, 2),
    basic_monthly_mean NUMERIC,
    basic_monthly_median NUMERIC,
    gross_monthly_mean NUMERIC,
    gross_monthly_median NUMERIC,
    gross_mthly_25_percentile NUMERIC,
    gross_mthly_75_percentile NUMERIC
);

COPY graduate_employment FROM 'D:\KJ BACKUP\Laptop Desktop\InsightBoard Graduate Employment Web Dashboard\GraduateEmploymentSurveyNTUNUSSITSMUSUSSSUTD.csv' DELIMITER ',' CSV HEADER NULL 'na';

ALTER TABLE graduate_employment
ADD COLUMN id SERIAL PRIMARY KEY;

GRANT ALL PRIVILEGES ON TABLE graduate_employment TO postgres;

