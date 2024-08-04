# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""

from flask_wtf import FlaskForm
from wtforms import TextField, PasswordField, StringField, TextAreaField
from wtforms.validators import DataRequired, Length, Email
from wtforms.validators import ValidationError

# login and registration


class LoginForm(FlaskForm):
    username = TextField('Username',
                         id='username_login',
                         validators=[DataRequired()])
    password = PasswordField('Password',
                             id='pwd_login',
                             validators=[DataRequired()])


class CreateAccountForm(FlaskForm):
    username = TextField('Username',
                         id='username_create',
                         validators=[DataRequired()])
    email = TextField('Email',
                      id='email_create',
                      validators=[DataRequired(), Email()])
    password = PasswordField('Password',
                             id='pwd_create',
                             validators=[DataRequired()])
    
class EmailWithTLD(object):
    valid_tlds = ['com', 'net', 'org', 'edu']  # Add any other TLDs you want to allow

    def __init__(self, message=None):
        if not message:
            message = f"Email must end with {', '.join('.' + tld for tld in self.valid_tlds)}"
        self.message = message

    def __call__(self, form, field):
        if not any(field.data.lower().endswith('.' + tld) for tld in self.valid_tlds):
            raise ValidationError(self.message)

class FeedbackForm(FlaskForm):
    name = StringField('Name', validators=[DataRequired(message="Name is required")])
    email = StringField('Email', validators=[
        DataRequired(message="Email is required"),
        Email(message="Invalid Email Format"),
        EmailWithTLD(message="Invalid Email Format")
    ])
    feedback = TextAreaField('Feedback', validators=[
        DataRequired(message="Feedback is required"), 
        Length(min=10, max=500, message="Feedback must be between 10 and 500 characters")
    ])
   