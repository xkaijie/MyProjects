# -*- encoding: utf-8 -*-
"""
Copyright (c) 2019 - present AppSeed.us
"""

import os
from decouple import config

class Config(object):

    basedir = os.path.abspath(os.path.dirname(__file__))

    # Set up the App SECRET_KEY
    SECRET_KEY = config('SECRET_KEY', default='S#perS3crEt_007')
    WTF_CSRF_ENABLED = True  
    # This will create a file in <app> FOLDER
    SQLALCHEMY_DATABASE_URI = 'sqlite:///' + os.path.join(basedir, 'db.sqlite3')
    SQLALCHEMY_TRACK_MODIFICATIONS = False

    
     # PostgreSQL Configuration for Graduate Employment Data
    SQLALCHEMY_BINDS = {
        'graduate_data': 'postgresql://postgres:admin@localhost/postgres',
        'feedback_data': 'postgresql://postgres:admin@localhost/postgres'
    }

    # Enable CSRF Protection globally
    WTF_CSRF_ENABLED = True
    
class ProductionConfig(Config):
    DEBUG = False

    # Security
    SESSION_COOKIE_HTTPONLY = True
    REMEMBER_COOKIE_HTTPONLY = True
    REMEMBER_COOKIE_DURATION = 3600
    # PostgreSQL Configuration - Updated URI for PostgreSQL
    SQLALCHEMY_DATABASE_URI = f"postgresql://{config('POSTGRESQL_USER')}:{config('POSTGRESQL_PASSWORD')}@{config('POSTGRESQL_HOST')}/{config('POSTGRESQL_DATABASE')}"

class DebugConfig(Config):
    DEBUG = True

class TestConfig(Config):
    TESTING = True
    SQLALCHEMY_DATABASE_URI = 'sqlite:///:memory:'
    SQLALCHEMY_BINDS = {
        'graduate_data': 'postgresql://postgres:admin@localhost/test_graduate_data',
    }
    SQLALCHEMY_TRACK_MODIFICATIONS = False

   
    # other testing-specific configurations


# Load all possible configurations
config_dict = {
    'Production': ProductionConfig,
    'Debug': DebugConfig,
    'Testing': TestConfig
}
