from unittest import TestCase
import geocode


class GetRemaining(TestCase):
    def test(self):
        db = geocode.connect_db()
        remaining = geocode.get_remaining(db)
        self.assertEqual(type(remaining).__name__, "int")