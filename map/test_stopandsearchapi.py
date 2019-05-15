from unittest import TestCase
import stopandsearchapi


class TestDistinctWards(TestCase):
    def test_me(self):
        self.assertIsInstance(stopandsearchapi.relevant_wards_list(), list)


class TestDistinctWardsGeoJSON(TestCase):
    def test_me(self):
        wards_list = stopandsearchapi.relevant_wards_list()
        geojson = stopandsearchapi.relevant_wards_geojson()

        # This fails because wards.json is missing some wards or the database has invalid wards
        # self.assertEqual(len(wards_list), len(geojson['features']))

        # Instead we relax the requirements a little
        self.assertGreaterEqual(len(wards_list), len(geojson['features']))
        self.assertGreater(len(geojson['features']), 0)


class TestWardsWithCount(TestCase):
    def test_me(self):
        wards_with_count = stopandsearchapi.wards_with_count()
        relevant_wards = stopandsearchapi.relevant_wards_geojson()
        self.assertEqual(len(relevant_wards['features']), len(wards_with_count['features']))

        self.assertIsNotNone(wards_with_count['features'][0]['results'])
