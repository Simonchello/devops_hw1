"""Exercise monitor.sh using isolated service commands and synthetic logs."""
import datetime as dt
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

SCRIPT = Path(__file__).resolve().parents[1] / 'scripts' / 'monitor.sh'

class MonitorTests(unittest.TestCase):
    def run_monitor(self, lines='', status='active', args=('docker',), missing=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            for name, body in {
                'systemctl': f'echo {status}\n' + ('exit 0\n' if status == 'active' else 'exit 3\n'),
                'journalctl': 'echo "journal fixture"\n',
            }.items():
                path = root / name
                path.write_text('#!/bin/sh\n' + body)
                path.chmod(0o755)
            log = root / 'syslog'
            if not missing:
                log.write_text(lines)
            env = dict(os.environ, PATH=f'{root}:{os.environ["PATH"]}', SYSLOG_PATH=str(log))
            return subprocess.run([str(SCRIPT), *args], env=env, text=True, capture_output=True)

    def test_time_window_and_formats(self):
        now = dt.datetime.now().astimezone()
        recent = now - dt.timedelta(minutes=5)
        old = now - dt.timedelta(hours=2)
        future = now + dt.timedelta(minutes=5)
        other_zone = recent.astimezone(dt.timezone(dt.timedelta(hours=5, minutes=30)))
        log = ''.join([
            f'{recent:%b %d %H:%M:%S} host service: ERROR one\n',
            f'{other_zone.isoformat()} host service: failed two\n',
            f'{recent.isoformat()} host service: healthy\n',
            f'{old.isoformat()} host service: fatal old\n',
            f'{future.isoformat()} host service: error future\n',
        ])
        result = self.run_monitor(log)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertIn('last hour: 2', result.stdout)

    def test_empty_log(self):
        result = self.run_monitor()
        self.assertEqual(result.returncode, 0)
        self.assertIn('last hour: 0', result.stdout)

    def test_inactive_and_unknown_service(self):
        for status in ('inactive', 'unknown'):
            result = self.run_monitor(status=status)
            self.assertEqual(result.returncode, 1)
            self.assertIn('journal fixture', result.stdout)

    def test_missing_log(self):
        result = self.run_monitor(missing=True)
        self.assertEqual(result.returncode, 2)
        self.assertIn('Cannot read', result.stderr)

    def test_invalid_arguments(self):
        for args in ((), ('--help',), ('docker', 'nginx'), ('bad/name',)):
            self.assertEqual(self.run_monitor(args=args).returncode, 2)

if __name__ == '__main__':
    unittest.main()
