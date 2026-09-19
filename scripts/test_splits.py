#!/usr/bin/env python3
"""Check that shared keys cannot resize Herdr behind a focused Neovim."""
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest

HELPER = Path(__file__).resolve().parents[1] / 'herdr/splits.py'


class SplitRouting(unittest.TestCase):
    def run_helper(self, processes, action, direction, fail_query=False):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            fake = root / 'herdr'
            fake.write_text('''#!/usr/bin/env python3
import json, os, sys
from pathlib import Path
with open(os.environ['CALLS'], 'a') as f:
    f.write(json.dumps(sys.argv[1:]) + '\\n')
if sys.argv[1:3] == ['pane', 'process-info']:
    if os.environ['FAIL_QUERY'] == '1': sys.exit(1)
    print(json.dumps({'result': {'process_info': {'foreground_processes': json.loads(os.environ['PROCESSES'])}}}))
''')
            fake.chmod(0o755)
            env = {**os.environ, 'HERDR_BIN_PATH': str(fake),
                   'HERDR_ACTIVE_PANE_ID': 'w2:p7', 'HERDR_PANE_ID': 'w9:p99', 'CALLS': str(root / 'calls'),
                   'PROCESSES': json.dumps(processes),
                   'FAIL_QUERY': '1' if fail_query else '0'}
            result = subprocess.run(['python3', str(HELPER), action, direction],
                                    env=env, capture_output=True, text=True)
            calls = [json.loads(line) for line in (root / 'calls').read_text().splitlines()]
            return result, calls

    def test_editor_gets_navigation_and_resize_keys(self):
        for action, modifiers in [('focus', 'ctrl'), ('resize', 'ctrl+shift+alt')]:
            for direction in ('left', 'down', 'up', 'right'):
                result, calls = self.run_helper([{'name': 'nvim'}], action, direction)
                self.assertEqual(result.returncode, 0, result.stderr)
                self.assertEqual(calls[-1], ['pane', 'send-keys', 'w2:p7', f'{modifiers}+{direction}'])

    def test_shell_uses_explicit_pane_and_fractional_resize(self):
        result, calls = self.run_helper([{'name': 'zsh'}], 'resize', 'right')
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(calls[-1], ['pane', 'resize', '--direction', 'right', '--pane', 'w2:p7', '--amount', '0.03'])

    def test_failed_detection_never_operates_on_outer_pane(self):
        result, calls = self.run_helper([], 'resize', 'left', fail_query=True)
        self.assertNotEqual(result.returncode, 0)
        self.assertEqual(len(calls), 1)


if __name__ == '__main__':
    unittest.main()
