"""Exercise deployment against an isolated home and source checkout."""
import json
import os
from pathlib import Path
import shutil
import subprocess
import tempfile
import unittest


class DeploymentTest(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.addCleanup(self.temp.cleanup)
        base = Path(self.temp.name).resolve()
        self.home = base / 'home'
        self.home.mkdir()
        self.repo = base / 'dotfiles'
        shutil.copytree(Path(__file__).resolve().parent.parent, self.repo,
                        ignore=shutil.ignore_patterns('.git', '__pycache__'))
        self.env = dict(os.environ, HOME=str(self.home))

    def run_deploy(self, *args, success=True):
        result = subprocess.run(['python3', str(self.repo / 'scripts/deploy.py'), *args],
                                env=self.env, text=True, capture_output=True)
        self.assertEqual(result.returncode == 0, success, result.stdout + result.stderr)
        return result.stdout

    def test_apply_idempotence_and_rollback(self):
        old = self.home / '.zshrc'
        old.write_text('# previous shell\n')
        self.run_deploy('preview')
        self.assertFalse((self.home / '.config').exists())
        out = self.run_deploy('apply')
        record = out.split('Rollback record: ')[1].strip()
        self.assertTrue((self.home / '.config/nvim').is_symlink())
        self.assertNotIn('Rollback record:', self.run_deploy('apply'))
        self.run_deploy('rollback', '--record', record)
        self.assertEqual(old.read_text(), '# previous shell\n')
        self.assertFalse((self.home / '.config/nvim').exists())

    def test_trust_stays_local_and_export_is_portable(self):
        config = self.home / '.codex/config.toml'
        config.parent.mkdir()
        local = '[projects."/private/project"]\ntrust_level = "trusted"\n'
        config.write_text('model = "old"\n' + local)
        out = self.run_deploy('apply', '--slice', 'agents')
        self.assertIn(local, config.read_text())
        hooks = self.home / '.codex/hooks.json'
        data = json.loads(hooks.read_text())
        data['description'] = 'Edited locally'
        data['hooks']['SessionStart'][0]['hooks'][0]['command'] = f"bash '{self.home}/.codex/herdr-agent-state.sh' session"
        hooks.write_text(json.dumps(data))
        self.run_deploy('export', '--slice', 'agents')
        self.assertNotIn('/private/project', (self.repo / 'agents/codex/config.toml').read_text())
        self.assertNotIn(str(self.home), (self.repo / 'agents/codex/hooks.json').read_text())
        exported = json.loads((self.repo / 'agents/codex/hooks.json').read_text())
        self.assertEqual(exported['description'], 'Edited locally')
        self.assertEqual(exported['hooks']['SessionStart'][0]['hooks'][0]['command'],
                         'bash "$HOME/.codex/herdr-agent-state.sh" session')
        config.write_text(config.read_text() + '\n# later edit\n')
        record = out.split('Rollback record: ')[1].strip()
        self.run_deploy('rollback', '--record', record, success=False)
        self.assertIn('# later edit', config.read_text())

    def test_unrelated_symlink_refused(self):
        (self.home / '.zshrc').symlink_to('/dev/null')
        self.run_deploy('apply', success=False)
        self.assertEqual(os.readlink(self.home / '.zshrc'), '/dev/null')


if __name__ == '__main__':
    unittest.main()
