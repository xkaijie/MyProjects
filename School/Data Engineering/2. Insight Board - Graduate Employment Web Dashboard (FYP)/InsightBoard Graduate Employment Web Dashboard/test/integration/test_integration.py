from selenium import webdriver
from selenium.webdriver.chrome.service import Service
from selenium.webdriver.common.by import By
import time
import os
import json

# Specify the path to the ChromeDriver executable
chrome_driver_path = 'C:/Users/KaiJie/Desktop/chromedriver-win64/chromedriver.exe'

if not os.path.exists(chrome_driver_path):
    raise FileNotFoundError(f"The path to ChromeDriver does not exist: {chrome_driver_path}")

# Create a Service object with the path to ChromeDriver
service = Service(chrome_driver_path)

# Initialize the WebDriver with the Service object
driver = webdriver.Chrome(service=service)

# Open your Flask web application login page
driver.get('http://127.0.0.1:5000/login')

# Find the login form elements and fill them in
username = driver.find_element(By.NAME, 'username')
password = driver.find_element(By.NAME, 'password')
login_button = driver.find_element(By.XPATH, '//button[@type="submit"]')

# Enter credentials and submit the form
username.send_keys('admin')
password.send_keys('admin')
login_button.click()

# Wait for the login process to complete
time.sleep(2)

# Define the endpoints to test
endpoints = [
    ('http://127.0.0.1:5000/index', 'dashboard_screenshot.png'),
    ('http://127.0.0.1:5000/filter-options', 'filter_options.json'),
    ('http://127.0.0.1:5000/employment-rate-chart-data', 'employment_rate_chart_data.json'),
    ('http://127.0.0.1:5000/employment-rate-by-degree-data', 'employment_rate_by_degree_data.json'),
    ('http://127.0.0.1:5000/basic-salary-data', 'basic_salary_data.json'),
    ('http://127.0.0.1:5000/average-salary-by-university', 'average_salary_by_university.json')
]

# Access each endpoint and capture the output
for url, output_file in endpoints:
    driver.get(url)
    time.sleep(20)  # Wait for the page to load

    # If the output is a screenshot
    if output_file.endswith('.png'):
        driver.save_screenshot(output_file)
    # If the output is JSON data
    elif output_file.endswith('.json'):
        # Extract the page content (assuming it is a JSON response)
        page_content = driver.find_element(By.TAG_NAME, 'body').text
        # Save the JSON response to a file
        with open(output_file, 'w') as f:
            f.write(page_content)

# Close the WebDriver
driver.quit()
