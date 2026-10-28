#!/usr/bin/env python3
"""Regression tests for run_tests.sh without needing a Godot installation.

    python3 -m unittest discover -s tests -p 'test_runner.py'
"""
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

ROOT = Path(__file__).resolve().parents[1]
RUNNER = ROOT / "tools" / "run_tests.sh"


class RunnerTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        self.directory = Path(self.temp.name)
        self.engine = self.directory / "godot"
        self.engine.write_text(
            "#!/bin/sh\n"
            "if [ \"$1\" = --version ]; then echo fake-engine; exit 0; fi\n"
            "case \"$*\" in\n"
            "  *\"$TEST_SUITE\"*)\n"
            "    case \"$TEST_RESULT\" in\n"
            "      exit) exit 7 ;;\n"
            "      timeout) exit 124 ;;\n"
            "      script_error) echo 'SCRIPT ERROR: simulated failure'; exit 0 ;;\n"
            "      engine_error) echo 'ERROR: failed loading resource'; exit 0 ;;\n"
            "      abort) runner=$(ps -o ppid= -p \"$PPID\" | tr -d ' '); kill -KILL \"$runner\"; exit 0 ;;\n"
            "    esac ;;\n"
            "esac\n"
            "echo ok\n"
        )
        self.engine.chmod(0o755)

    def run_tier(self, jobs, result="pass", suite="city_integration_test.gd", tier="--quick"):
        env = dict(os.environ, GODOT=str(self.engine), JOBS=str(jobs),
                   TEST_LOG_DIR=str(self.directory / "logs"),
                   TEST_SUITE=suite, TEST_RESULT=result)
        return subprocess.run([str(RUNNER), tier], cwd=ROOT, env=env,
                              text=True, capture_output=True, timeout=30)

    def test_list_does_not_require_godot(self):
        env = dict(os.environ, GODOT="missing-engine")
        proc = subprocess.run([str(RUNNER), "--list"], cwd=ROOT, env=env,
                              text=True, capture_output=True, timeout=10)
        self.assertEqual(proc.returncode, 0, proc.stderr)
        self.assertIn("city_integration_test.gd", proc.stdout)
        self.assertIn("balance_matrix_test.gd", proc.stdout)

    def test_range_tier_excludes_campaign_scenarios(self):
        proc = self.run_tier(1, tier="--range")
        self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)
        self.assertIn("test_range_regression_test", proc.stdout)
        self.assertIn("test_range_replays_test", proc.stdout)
        self.assertIn("test_range_determinism_test", proc.stdout)
        self.assertIn("habits_test", proc.stdout)
        self.assertNotRegex(proc.stdout, r"(?m)^\s*PASS\s+determinism_test\s")
        self.assertNotIn("orders_test", proc.stdout)

    def test_serial_and_parallel_pass(self):
        for jobs in (1, 2):
            with self.subTest(jobs=jobs):
                proc = self.run_tier(jobs)
                self.assertEqual(proc.returncode, 0, proc.stdout + proc.stderr)
                self.assertIn("fail: 0", proc.stdout)

    def test_nonzero_exit_is_not_lost_in_parallel(self):
        for jobs in (1, 2):
            with self.subTest(jobs=jobs):
                proc = self.run_tier(jobs, "exit")
                self.assertEqual(proc.returncode, 1, proc.stdout + proc.stderr)
                self.assertIn("city_integration_test.gd", proc.stdout)
                self.assertIn("fail: 1", proc.stdout)

    def test_script_errors_and_timeouts_fail(self):
        for jobs in (1, 2):
            with self.subTest(jobs=jobs, failure="script_error"):
                proc = self.run_tier(jobs, "script_error")
                self.assertEqual(proc.returncode, 1, proc.stdout + proc.stderr)
            with self.subTest(jobs=jobs, failure="engine_error"):
                proc = self.run_tier(jobs, "engine_error")
                self.assertEqual(proc.returncode, 1, proc.stdout + proc.stderr)
            with self.subTest(jobs=jobs, failure="timeout"):
                proc = self.run_tier(jobs, "timeout")
                self.assertEqual(proc.returncode, 3, proc.stdout + proc.stderr)
                self.assertIn("timeout: 1", proc.stdout)

    def test_stale_status_files_cannot_mask_failed_children(self):
        self.run_tier(2)
        proc = self.run_tier(2, "abort")
        self.assertEqual(proc.returncode, 1, proc.stdout + proc.stderr)
        self.assertNotIn("all selected suites passed", proc.stdout)


if __name__ == "__main__":
    unittest.main()
