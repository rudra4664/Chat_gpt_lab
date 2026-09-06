import unittest
from app import app

class AppTests(unittest.TestCase):
    def test_health(self):
        response = app.test_client().get('/health')
        self.assertEqual(response.status_code, 200)
        self.assertEqual(response.json, {'status':'ok'})
    def test_application_identity(self):
        response = app.test_client().get('/')
        self.assertEqual(response.json['application'], 'flask-learning-lab')

if __name__ == '__main__': unittest.main()
