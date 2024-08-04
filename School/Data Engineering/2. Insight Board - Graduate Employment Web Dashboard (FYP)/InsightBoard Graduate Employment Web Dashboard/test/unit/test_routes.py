# test/test_routes.py

import pytest
from flask import template_rendered, Flask
from flask.testing import FlaskClient
from flask.templating import Template
from apps import db
from contextlib import contextmanager
from typing import List, Tuple, Dict, Any, Generator
from apps.authentication.models import Users
from werkzeug.security import generate_password_hash
import warnings
warnings.filterwarnings("ignore", category=DeprecationWarning)

@pytest.fixture(scope='function')
def client_with_auth(client: FlaskClient, app: Flask) -> Generator[FlaskClient, None, None]:
    with app.app_context():
        user = Users.query.first()
        if user is None:
            user = Users(username='admin', email='asdsadsad@sadadas.com', password=generate_password_hash('admin'))
            db.session.add(user)
            db.session.commit()
        
        with client.session_transaction() as session:
            session['_user_id'] = user.id  # Manually setting the user ID in the session
        yield client

@contextmanager
def captured_templates(app: Flask) -> Generator[List[Tuple[Template, Dict[str, Any]]], None, None]:
    recorded: List[Tuple[Template, Dict[str, Any]]] = []

    def record(sender: Flask, template: Template, context: Dict[str, Any], **extra: Any) -> None:
        recorded.append((template, context))

    template_rendered.connect(record, app)
    try:
        yield recorded
    finally:
        template_rendered.disconnect(record, app)

def test_index_route(client_with_auth: FlaskClient):
    """Test the index route that requires authentication."""
    response = client_with_auth.get('/index')
    assert response.status_code == 200
    assert 'Welcome' in response.get_data(as_text=True)
