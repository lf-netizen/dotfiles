#!/usr/bin/env python3
"""Verify/install official integrations, then export the resulting settings."""
import json
from pathlib import Path
import shutil
import subprocess
import sys
import tomllib

root = Path(__file__).resolve().parent.parent
for command in ('herdr', 'claude', 'codex', 'python3'):
    if not shutil.which(command):
        sys.exit(f'Missing prerequisite: {command}')
status = subprocess.check_output(['herdr', 'integration', 'status'], text=True)
for agent, rel in [('claude', '.claude/settings.json'), ('codex', '.codex/hooks.json')]:
    path = Path.home()/rel
    if not path.exists():
        sys.exit(f'Deploy agent settings first: {path}')
    data = json.loads(path.read_text())
    commands = [h.get('command','') for g in data.get('hooks',{}).get('SessionStart',[]) for h in g.get('hooks',[])]
    registered = sum('herdr-agent-state.sh' in command for command in commands) == 1
    current = any(line.startswith(f'{agent}: current ') for line in status.splitlines())
    hooks_enabled = agent != 'codex' or tomllib.loads((Path.home()/'.codex/config.toml').read_text()).get('features', {}).get('hooks') is True
    if not (current and registered and hooks_enabled):
        subprocess.run(['herdr', 'integration', 'install', agent], check=True)
    else:
        print(f'{agent}: current and registered; unchanged')
    data = json.loads(path.read_text())
    commands = [h.get('command','') for g in data.get('hooks',{}).get('SessionStart',[]) for h in g.get('hooks',[])]
    assert sum('herdr-agent-state.sh' in c for c in commands) == 1
subprocess.run(['herdr', 'integration', 'status'], check=True)
subprocess.run([str(root/'scripts/symlinks.sh'), 'export', '--slice', 'agents'], check=True)
