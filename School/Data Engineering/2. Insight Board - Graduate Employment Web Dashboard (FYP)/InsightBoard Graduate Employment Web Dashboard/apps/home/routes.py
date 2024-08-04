# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""
from apps.home import blueprint
from flask import render_template, request, send_file
from flask_login import login_required, login_user
from jinja2 import TemplateNotFound
from apps.authentication.models import GraduateEmployment, Users
from flask import jsonify
from apps import db, login_manager
from sqlalchemy import func,cast, Integer
from flask import flash, redirect, url_for, flash, request, current_app
from apps.authentication.models import Feedback  
from apps.authentication.forms import FeedbackForm
import pandas as pd
import os
from io import BytesIO
import xlsxwriter
import numpy as np
from flask_wtf.csrf import generate_csrf, validate_csrf
import logging
logging.basicConfig(level=logging.DEBUG)
import jwt
from functools import wraps

# Add the login route
@blueprint.route('/login', methods=['POST'])
def login():
    data = request.get_json()
    username = data.get('username')
    password = data.get('password')

    user = Users.query.filter_by(username=username).first()
    if user and user.check_password(password):
        login_user(user)
        token = user.get_jwt_token()
        return jsonify({'token': token})
    return jsonify({'message': 'Invalid credentials'}), 401

def token_required(f):
    @wraps(f)
    def decorated(*args, **kwargs):
        token = None
        if 'Authorization' in request.headers:
            token = request.headers['Authorization'].split(" ")[1]
        if not token:
            return jsonify({'message': 'Token is missing!'}), 401
        try:
            data = jwt.decode(token, current_app.config['SECRET_KEY'], algorithms=["HS256"])
            current_user = Users.query.filter_by(id=data['user_id']).first()
        except Exception as e:
            return jsonify({'message': 'Token is invalid!'}), 401
        return f(current_user, *args, **kwargs)
    return decorated

# =======================================================
@blueprint.route('/filter-options')
@login_required
def filter_options():
    years = sorted(set([year.year for year in GraduateEmployment.query.distinct(GraduateEmployment.year)]))
    universities = sorted(set([uni.university for uni in GraduateEmployment.query.distinct(GraduateEmployment.university)]))
    degree_categories = sorted([category.degree_category for category in GraduateEmployment.query.with_entities(GraduateEmployment.degree_category).distinct()])

    return jsonify({
        'years': years,
        'universities': universities,
        'degree_categories': degree_categories
    })
@blueprint.route('/degrees-in-other')
@login_required
def degrees_in_other():
    # Query all degrees that have 'Other' as their category
    other_degrees = [degree.degree for degree in GraduateEmployment.query.filter_by(degree_category="Interdisciplinary Studies")]

    # Return the list of 'Other' degrees as a JSON response
    return jsonify({
        'other_degrees': other_degrees
    })
# update key metrics for real time filtering
@blueprint.route('/update-metrics')
@login_required
def update_metrics():
    year = request.args.get('year', default=None, type=str)
    university = request.args.get('university', default=None, type=str)
    degree_category = request.args.get('degree', default=None, type=str)

    # Helper function to calculate differences
    def calculate_difference(current, previous):
        if current is None or previous is None:
            return "N/A"
        try:
            return "{:.2f}%".format((current - previous) / previous * 100)
        except ZeroDivisionError:
            return "N/A"

    query_current = GraduateEmployment.query
    query_previous = GraduateEmployment.query

    if year:
        query_current = query_current.filter(cast(GraduateEmployment.year, Integer) == int(year))
        query_previous = query_previous.filter(cast(GraduateEmployment.year, Integer) == int(year) - 1)
    if university:
        query_current = query_current.filter(GraduateEmployment.university == university)
        query_previous = query_previous.filter(GraduateEmployment.university == university)
    if degree_category:
        query_current = query_current.filter(GraduateEmployment.degree_category == degree_category)
        query_previous = query_previous.filter(GraduateEmployment.degree_category == degree_category)

    def safe_float(value):
        try:
            return float(value)
        except TypeError:
            return None

    metrics_current = {
        'graduate_count': query_current.count(),
        'average_employment_rate': safe_float(query_current.with_entities(func.avg(GraduateEmployment.employment_rate_overall)).scalar()),
        'ft_perm_employment_rate': safe_float(query_current.with_entities(func.avg(GraduateEmployment.employment_rate_ft_perm)).scalar()),
        'median_gross_monthly_salary': safe_float(query_current.with_entities(func.percentile_cont(0.5).within_group(GraduateEmployment.gross_monthly_mean)).scalar())
    }
    metrics_previous = {
        'graduate_count': query_previous.count(),
        'average_employment_rate': safe_float(query_previous.with_entities(func.avg(GraduateEmployment.employment_rate_overall)).scalar()),
        'ft_perm_employment_rate': safe_float(query_previous.with_entities(func.avg(GraduateEmployment.employment_rate_ft_perm)).scalar()),
        'median_gross_monthly_salary': safe_float(query_previous.with_entities(func.percentile_cont(0.5).within_group(GraduateEmployment.gross_monthly_mean)).scalar())
    }

    differences = {
        'graduate_count_diff': calculate_difference(metrics_current['graduate_count'], metrics_previous['graduate_count']),
        'average_employment_rate_diff': calculate_difference(metrics_current['average_employment_rate'], metrics_previous['average_employment_rate']),
        'ft_perm_employment_rate_diff': calculate_difference(metrics_current['ft_perm_employment_rate'], metrics_previous['ft_perm_employment_rate']),
        'median_gross_monthly_salary_diff': calculate_difference(metrics_current['median_gross_monthly_salary'], metrics_previous['median_gross_monthly_salary']),
    }

    return jsonify({
        **metrics_current,
        **differences
    })


# 1. Emplyoment Rate over time 
@blueprint.route('/employment-rate-chart-data')
@login_required
def employment_rate_chart_data():
    year = request.args.get('year', default=None, type=str)
    university = request.args.get('university', default=None, type=str)
    degree_category = request.args.get('degree', default=None, type=str)

    query = GraduateEmployment.query
    if year:
        query = query.filter(cast(GraduateEmployment.year, Integer) == int(year)) # Convert year to int here
    if university:
        query = query.filter(GraduateEmployment.university == university)
    if degree_category:
        query = query.filter(GraduateEmployment.degree_category == degree_category)
    
    employment_data = query.all()
    chart_data = prepare_chart_data(employment_data)

    return jsonify(chart_data)

# ====================================================================================
def prepare_chart_data(data):
    # Group employment data by year and calculate the average employment rate for each year
    avg_employment_rate_by_year = {}
    for record in data:
        year = record.year
        employment_rate = record.employment_rate_overall
        # Make sure each year is accounted for properly
        if year not in avg_employment_rate_by_year:
            avg_employment_rate_by_year[year] = []
        avg_employment_rate_by_year[year].append(employment_rate)

    # Prepare sorted lists for years and their average employment rates
    sorted_years = sorted(avg_employment_rate_by_year.keys())
    avg_employment_rates = [sum(avg_employment_rate_by_year[year]) / len(avg_employment_rate_by_year[year]) for year in sorted_years]

    # Preparing the data in the format expected by Plotly
    chart_data = [{
        'x': sorted_years,
        'y': avg_employment_rates,
        'type': 'line',  # Specify a line chart
        'name': 'Average Employment Rate'
    }]
    return chart_data


# 4. employment rate by degree bar chart
@blueprint.route('/employment-rate-by-degree-data')
@login_required
def employment_rate_by_degree_data():
    year = request.args.get('year')
    university = request.args.get('university')
    degree = request.args.get('degree')

    # Begin your query
    query = GraduateEmployment.query

    # Apply filters
    if year:
        query = query.filter_by(year=year)
    if university:
        query = query.filter_by(university=university)
    if degree:
        query = query.filter_by(degree_category=degree)

    # Group by degree and calculate average employment rate
    results = (query
               .group_by(GraduateEmployment.degree_category)
               .with_entities(
                   GraduateEmployment.degree_category.label('degree'),
                   func.avg(GraduateEmployment.employment_rate_overall).label('average_rate'))
               .all())

    # Format the data for Plotly
    data = {
        'degrees': [result.degree for result in results],
        'average_rates': [float(result.average_rate) if result.average_rate else None for result in results]
    }
    return jsonify(data)

# ======================= 3. basic salary chart ==============================================
@blueprint.route('/basic-salary-data')
@login_required
def basic_salary_data():
    year = request.args.get('year')
    university = request.args.get('university')
    degree = request.args.get('degree')

    query = GraduateEmployment.query

    if year:
        query = query.filter_by(year=year)
    if university:
        query = query.filter_by(university=university)
    if degree:
        query = query.filter_by(degree_category=degree)

    # Fetch basic monthly mean salaries with the applied filters
    salaries = [salary.basic_monthly_mean for salary in query.all() if salary.basic_monthly_mean is not None]

    return jsonify(salaries)

# ====================== 2. avg salary university ===========================================
@blueprint.route('/average-salary-by-university')
@login_required
def average_salary_by_university():
     # Retrieve filter values from the query parameters
    year = request.args.get('year')
    university_filter = request.args.get('university')
    degree_filter = request.args.get('degree')

    # Start building the query
    query = db.session.query(
        GraduateEmployment.university.label('university'),
        func.avg(GraduateEmployment.gross_monthly_mean).label('average_salary')
    )

    # Apply filters if they are provided
    if year:
        query = query.filter(GraduateEmployment.year == year)
    if university_filter:
        query = query.filter(GraduateEmployment.university == university_filter)
    if degree_filter:
        query = query.filter(GraduateEmployment.degree_category == degree_filter)

    # Group by university and get the results
    salary_data = query.group_by(GraduateEmployment.university).all()

    # Convert the query results to a dictionary for JSON response
    response_data = {
        'universities': [data.university for data in salary_data],
        'average_salaries': [float(data.average_salary) if data.average_salary else None for data in salary_data]
    }

    return jsonify(response_data)
# ====================== Key Metrices ==============================================
@blueprint.route('/index')
#@token_required
def index():
    # Count the number of graduates
    graduate_count = db.session.query(func.count(GraduateEmployment.id)).scalar()

    # Calculate the average employment rate with 2 decimal places
    average_employment_rate = db.session.query(func.avg(GraduateEmployment.employment_rate_overall)).scalar()
    average_employment_rate_formatted = "{:.2f}".format(average_employment_rate) if average_employment_rate is not None else None

    # Calculate the Employment Rate for Full-Time Permanent Positions with 2 decimal places
    ft_perm_employment_rate = db.session.query(func.avg(GraduateEmployment.employment_rate_ft_perm)).scalar()
    ft_perm_employment_rate_formatted = "{:.2f}".format(ft_perm_employment_rate) if ft_perm_employment_rate is not None else None

    # Calculate the Median Gross Monthly Salary
    median_gross_monthly_salary = db.session.query(func.percentile_cont(0.5).within_group(GraduateEmployment.gross_monthly_mean)).scalar()
    median_gross_monthly_salary_formatted = "${:,.2f}".format(median_gross_monthly_salary) if median_gross_monthly_salary is not None else None

    # Querying the graduate employment data from PostgreSQL
    employment_data = GraduateEmployment.query.all()

    # For demonstration, let's assume you have a function like this:
    chart_data = prepare_chart_data(employment_data)

    # Check if data was found
    if not employment_data:
        print("No data found!")  # This will print to the Flask server console

   # Render one template with both datasets passed as context
    return render_template('home/index.html', segment='index', employment_data=employment_data, chart_data=chart_data, graduate_count=graduate_count, average_employment_rate=average_employment_rate_formatted, ft_perm_employment_rate=ft_perm_employment_rate_formatted, median_gross_monthly_salary=median_gross_monthly_salary_formatted)

from markupsafe import Markup
@blueprint.route('/feedback', methods=['GET', 'POST'])
def feedback():
    form = FeedbackForm()  # Instantiate the form
    # wrap the HTML strings with Markup
    form.name.label.text = Markup('Name <span class="text-danger">  ** Required **</span>')
    form.email.label.text = Markup('Email <span class="text-danger"> ** Required **</span>')
    form.feedback.label.text = Markup('Feedback <span class="text-danger"> ** Required **</span>')
    segment = request.path.split('/')[-1]  # This will be 'feedback'

    if request.method == 'POST' and form.validate_on_submit():
        try:
            # Assuming you have a method to process the form data
            submit_feedback(form)
            flash('Feedback submitted successfully!', 'success')
            return redirect(url_for('home_blueprint.feedback'))
        except Exception as e:
            flash('An error occurred. Please try again.', 'error')
            current_app.logger.error('Feedback submission failed: %s', e)

    # Pass both the form and segment to the template
    return render_template('home/feedback.html', form=form, segment=segment)

@blueprint.route('/submit-feedback', methods=['POST'])
def submit_feedback():
    form = FeedbackForm()
    if form.validate_on_submit():
        try:
            new_feedback = Feedback(name=form.name.data, email=form.email.data, feedback=form.feedback.data)
            db.session.add(new_feedback)
            db.session.commit()
            flash('Feedback submitted successfully!', 'success')
        except Exception as e:
            db.session.rollback()
            flash('An error occurred. Please try again.', 'error')
            print(f"Error: {e}")  # Log the error for debugging
    else:
        # If the form does not validate, flash messages for each field error
        for field, errors in form.errors.items():
            for error in errors:
                flash(f"Error in the {getattr(form, field).label.text} field - {error}", 'error')

    return redirect(url_for('home_blueprint.feedback', form=form))
# ===================================================================
@blueprint.route('/fetch-dashboard-data')
@login_required
def fetch_dashboard_data(year=None, university=None, degree=None):
    # Establish the base query for fetching the graduate employment data
    base_query = GraduateEmployment.query
    
    # Apply filters based on provided parameters
    if year is not None:
        base_query = base_query.filter(cast(GraduateEmployment.year, Integer) == year)
    if university:
        base_query = base_query.filter(GraduateEmployment.university == university)
    if degree:
        base_query = base_query.filter(GraduateEmployment.degree_category == degree)

    # Fetch key metrics data using the filtered query
    annual_summary = base_query.with_entities(
        GraduateEmployment.year.label("Year"),
        func.count(GraduateEmployment.id).label("Graduate Count"),
        func.avg(GraduateEmployment.employment_rate_overall).label("Average Employment Rate"),
        func.avg(GraduateEmployment.employment_rate_ft_perm).label("FT Perm Employment Rate"),
        func.percentile_cont(0.5).within_group(GraduateEmployment.gross_monthly_median).label("Gross Median Monthly Salary")
    ).group_by(GraduateEmployment.year).all()

    # Fetch additional data for charts based on filters
    # Employment Rate Over Time
    employment_rate_over_time = base_query.with_entities(
        GraduateEmployment.year.label('Year'),
        func.avg(GraduateEmployment.employment_rate_overall).label('Average Employment Rate')
    ).group_by(GraduateEmployment.year).order_by(GraduateEmployment.year).all()

    # Gross Mean Monthly Salary by University
    gross_mean_salary_by_university = base_query.with_entities(
        GraduateEmployment.university.label('University'),
        func.avg(GraduateEmployment.gross_monthly_mean).label('Gross Monthly Mean')
    ).group_by(GraduateEmployment.university).all()

    # Starting Salary Distribution
    starting_salary_distribution = base_query.with_entities(
        GraduateEmployment.basic_monthly_mean.label('Basic Monthly Mean'),
        func.count(GraduateEmployment.basic_monthly_mean).label('Count')  # Add the count
    ).group_by(GraduateEmployment.basic_monthly_mean)

    # Average Employment Rate by Degree
    average_employment_rate_by_degree = base_query.with_entities(
        GraduateEmployment.degree_category.label('Degree'),
        func.avg(GraduateEmployment.employment_rate_overall).label('Average Employment Rate')
    ).group_by(GraduateEmployment.degree_category).all()

    # Convert query results to DataFrames for easier manipulation if needed
    df_metrics = pd.DataFrame(annual_summary, columns=["Year", "Graduate Count", "Average Employment Rate", "FT Perm Employment Rate", "Gross Median Monthly Salary"])
    df_employment_rate_over_time = pd.DataFrame(employment_rate_over_time)
    df_gross_mean_salary_by_university = pd.DataFrame(gross_mean_salary_by_university)
    df_starting_salary_distribution = pd.DataFrame(starting_salary_distribution)
    df_average_employment_rate_by_degree = pd.DataFrame(average_employment_rate_by_degree)

    # Combine all data into a dictionary to return
    data = {
        'metrics': df_metrics,
        'employment_rate_over_time': df_employment_rate_over_time,
        'gross_mean_salary_by_university': df_gross_mean_salary_by_university,
        'starting_salary_distribution': df_starting_salary_distribution,
        'average_employment_rate_by_degree': df_average_employment_rate_by_degree
    }

    return data


# ==============================================================================
@blueprint.route('/export/dashboard', methods=['GET'])
@login_required
def export_dashboard():
    # Retrieve filter values from the query parameters
    year = request.args.get('year', default=None, type=int)
    university = request.args.get('university', default=None, type=str)
    degree = request.args.get('degree', default=None, type=str)


    # Pass the filter parameters to the fetch_dashboard_data function
    data_dict = fetch_dashboard_data(year=year, university=university, degree=degree)
    if data_dict['metrics'].empty:
        flash('No data to export', 'warning')
        return redirect(url_for('home_blueprint.index'))

    output = BytesIO()
    with pd.ExcelWriter(output, engine='xlsxwriter') as writer:
        workbook = writer.book
        dashboard_sheet = workbook.add_worksheet('Dashboard')

        # Format definitions
        header_format = workbook.add_format({'bold': True, 'align': 'center', 'valign': 'vcenter', 'fg_color': '#5e72e4', 'border': 1})
        number_format_2dp = workbook.add_format({'num_format': '#,##0.00'})
        title_format = workbook.add_format({'bold': True, 'font_size': 14})
        
        
        # Set the column widths and apply the number format for the header row
        dashboard_sheet.set_column('B:B', 20, number_format_2dp)  # Assuming 'Year' is in column A
        dashboard_sheet.set_column('C:D', 25, number_format_2dp)  # Assuming the numeric columns to format are from B to D
        dashboard_sheet.set_column('E:E', 25, number_format_2dp)
        dashboard_sheet.set_column('A:A', 35)
        dashboard_sheet.merge_range('A1:E1', 'Annual Summary', title_format)

        start_row = 3
        numeric_columns = ["Year", "Average Employment Rate", "FT Perm Employment Rate", "Employment Rate", "Gross Monthly Mean"]
        sections = ['metrics', 'employment_rate_over_time', 'gross_mean_salary_by_university',
                    'starting_salary_distribution', 'average_employment_rate_by_degree']

        for key in sections:
            df = data_dict[key]
            if df.empty:
                continue  # Skip sections with no data
            current_start_row = start_row
            current_start_col = 0

            # Convert specified columns to numeric, ignoring errors to skip non-convertible values
            for column in numeric_columns:
                if column in df.columns:
                    df[column] = pd.to_numeric(df[column], errors='coerce')

            # Writing the DataFrame to the Excel sheet
            df.to_excel(writer, sheet_name='Dashboard', startrow=current_start_row, 
                        startcol=current_start_col, index=False, header=False)
            dashboard_sheet.write_row(current_start_row - 1, current_start_col, 
                                      df.columns.tolist(), header_format)
            
            # Write the section header explicitly if needed
            if key == 'starting_salary_distribution':
                dashboard_sheet.write_row(current_start_row - 1, current_start_col, 
                                      ['Basic Monthly Mean', 'Count'], header_format)
                current_start_row += 1  # Move down to accommodate the new header

            start_row += len(df.index) + 4  # Leave some space for the chart
            # Correct specific cell texts after all dynamic content is written
        dashboard_sheet.hide_gridlines(2)

    output.seek(0)
    return send_file(output, attachment_filename='dashboard_data.xlsx', as_attachment=True)

# =====================================================================================z
@blueprint.route('/<template>')
@login_required
def route_template(template):

    try:

        if not template.endswith('.html'):
            template += '.html'

        # Detect the current page
        segment = get_segment(request)

        # Serve the file (if exists) from app/templates/home/FILE.html
        return render_template("home/" + template, segment=segment)

    except TemplateNotFound:
        return render_template('home/page-404.html'), 404

    except:
        return render_template('home/page-500.html'), 500


# Helper - Extract current page name from request
def get_segment(request):

    try:

        segment = request.path.split('/')[-1]

        if segment == '':
            segment = 'index'

        return segment

    except:
        return None
