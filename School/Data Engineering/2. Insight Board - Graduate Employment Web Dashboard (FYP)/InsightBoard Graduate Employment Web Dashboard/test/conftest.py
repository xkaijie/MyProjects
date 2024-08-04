# test/conftest.py

import pytest
from apps import create_app, db
from apps.config import TestConfig
from flask import Flask
from flask.testing import FlaskClient
from typing import Generator

@pytest.fixture(scope='session')
def app() -> Generator[Flask, None, None]:
    app = create_app(TestConfig)
    with app.app_context():
        db.create_all()  # This will handle both SQLite and PostgreSQL tables
    yield app
    with app.app_context():
        db.drop_all()

@pytest.fixture(scope='function')
def client(app: Flask) -> FlaskClient:
    return app.test_client()

