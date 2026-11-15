"""Vérifie le traitement des observations récentes et périmées, sans Internet."""
import datetime as dt
import json
import pathlib
import shutil
import subprocess
import tempfile
import unittest

SCRIPT = pathlib.Path(__file__).resolve().parents[1] / 'RainmakerSunWidget' / '@Resources' / 'actualiser.ps1'


class SolarFeedTests(unittest.TestCase):
    def run_feeds(self, age_minutes):
        with tempfile.TemporaryDirectory() as folder:
            root = pathlib.Path(folder)
            source = root / 'resources'
            source.mkdir()
            script = source / 'actualiser.ps1'
            shutil.copyfile(SCRIPT, script)
            fixtures = root / 'fixtures'
            fixtures.mkdir()
            stamp = (dt.datetime.now(dt.timezone.utc) - dt.timedelta(minutes=age_minutes)).strftime('%Y-%m-%dT%H:%M:%SZ')
            data = {
                'xray': [{'time_tag': stamp, 'current_class': 'B5.9', 'max_time': stamp, 'max_class': 'C1.0'}],
                'vent': [{'time_tag': stamp, 'proton_speed': 363}],
                'bz': [{'time_tag': stamp, 'bz_gsm': -2.5}],
                'flux': [{'time_tag': stamp, 'flux': 124}],
            }
            for name, value in data.items():
                (fixtures / (name + '.json')).write_text(json.dumps(value), encoding='utf-8')
            subprocess.run(['powershell.exe', '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-File', str(script), '-FixtureDirectory', str(fixtures)], check=True, timeout=30)
            result = (source / 'donnees.inc').read_text(encoding='utf-16')
            return dict(line.split('=', 1) for line in result.splitlines() if '=' in line)

    def test_recent_measurements_and_separate_peak(self):
        data = self.run_feeds(5)
        self.assertEqual(data['Rayons'], 'B5.9')
        self.assertEqual(data['Eruption'], 'C1.0')
        self.assertEqual(data['Vent'], '363')
        self.assertEqual(data['Bz'], '-2.5')
        self.assertEqual(data['Flux'], '124')
        self.assertEqual(data['PremierDemarrage'], '0')

    def test_stale_measurements_are_hidden(self):
        data = self.run_feeds(5000)
        for name in ('Rayons', 'Vent', 'Bz', 'Flux'):
            self.assertEqual(data[name], '--')
        self.assertEqual(data['Eruption'], 'C1.0')
        self.assertNotEqual(data['EruptionHeure'], '--')


if __name__ == '__main__':
    unittest.main()
