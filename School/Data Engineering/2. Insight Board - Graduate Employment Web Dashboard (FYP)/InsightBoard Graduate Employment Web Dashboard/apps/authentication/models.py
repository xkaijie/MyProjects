# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""

from flask_login import UserMixin
import jwt
from time import time
from flask import current_app
from apps import db, login_manager

from apps.authentication.util import hash_pass

class Users(db.Model, UserMixin):

    __tablename__ = 'Users'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)  
    email = db.Column(db.String(120), unique=True, nullable=False) 
    password = db.Column(db.LargeBinary)

    def __init__(self, **kwargs):
        for property, value in kwargs.items():
            # depending on whether value is an iterable or not, we must
            # unpack it's value (when **kwargs is request.form, some values
            # will be a 1-element list)
            if hasattr(value, '__iter__') and not isinstance(value, str):
                # the ,= unpack of a singleton fails PEP8 (travis flake8 test)
                value = value[0]

            if property == 'password':
                value = hash_pass(value)  # we need bytes here (not plain str)

            setattr(self, property, value)

    def __repr__(self):
        return str(self.username)
    
    def get_jwt_token(self, expires_in=600):
        return jwt.encode(
            {'user_id': self.id, 'exp': time() + expires_in},
            current_app.config['SECRET_KEY'], algorithm='HS256'
        )

class TestUsers(db.Model, UserMixin):

    __tablename__ = 'TestUsers'

    id = db.Column(db.Integer, primary_key=True)
    username = db.Column(db.String(80), unique=True, nullable=False)  
    email = db.Column(db.String(120), unique=True, nullable=False) 
    password = db.Column(db.LargeBinary)

    def __init__(self, **kwargs):
        for property, value in kwargs.items():
            # depending on whether value is an iterable or not, we must
            # unpack it's value (when **kwargs is request.form, some values
            # will be a 1-element list)
            if hasattr(value, '__iter__') and not isinstance(value, str):
                # the ,= unpack of a singleton fails PEP8 (travis flake8 test)
                value = value[0]

            if property == 'password':
                value = hash_pass(value)  # we need bytes here (not plain str)

            setattr(self, property, value)

    def __repr__(self):
        return str(self.username)
    
    

class GraduateEmployment(db.Model):
    __bind_key__ = 'graduate_data'  # This tells SQLAlchemy to use the PostgreSQL database for this model
    __tablename__ = 'graduate_employment'
    id = db.Column(db.Integer, primary_key=True)
    year = db.Column(db.String(4))
    university = db.Column(db.String(255))
    school = db.Column(db.String(255))
    degree = db.Column(db.String(255))
    degree_category = db.Column(db.String(255)) 
    employment_rate_overall = db.Column(db.Float)
    employment_rate_ft_perm = db.Column(db.Float)
    basic_monthly_mean = db.Column(db.Float)
    basic_monthly_median = db.Column(db.Float)
    gross_monthly_mean = db.Column(db.Float)
    gross_monthly_median = db.Column(db.Float)
    gross_mthly_25_percentile = db.Column(db.Float)
    gross_mthly_75_percentile = db.Column(db.Float)

class Feedback(db.Model):
    __bind_key__ = 'feedback_data' 
    __tablename__ = 'feedback'

    id = db.Column(db.Integer, primary_key=True)
    name = db.Column(db.String(255), nullable=False)
    email = db.Column(db.String(255), nullable=False)
    feedback = db.Column(db.Text, nullable=False)
    created_at = db.Column(db.DateTime, default=db.func.current_timestamp())

    def __init__(self, name, email, feedback):
        self.name = name
        self.email = email
        self.feedback = feedback

@login_manager.user_loader
def user_loader(id):
    return Users.query.filter_by(id=id).first()


@login_manager.request_loader
def request_loader(request):
    username = request.form.get('username')
    user = Users.query.filter_by(username=username).first()
    return user if user else None
