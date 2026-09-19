#!/usr/bin/env python3
"""Route shared split keys to Neovim, or operate on the Herdr pane."""
import argparse
import json
import os
from pathlib import Path
import re
import subprocess
import sys


def route(action, direction, processes, pane):
    editor = any(re.fullmatch(r'g?(view|l?n?vim?x?)(diff)?',
                             Path(process['name']).name.lower())
                 for process in processes)
    if editor:
        modifiers = 'ctrl' if action == 'focus' else 'ctrl+shift+alt'
        return ['send-keys', pane, f'{modifiers}+{direction}']
    args = [action, '--direction', direction, '--pane', pane]
    if action == 'resize':
        args.extend(['--amount', '0.03'])
    return args


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['focus', 'resize'])
    parser.add_argument('direction', choices=['left', 'down', 'up', 'right'])
    args = parser.parse_args()
    binary = os.environ.get('HERDR_BIN_PATH') or '/opt/homebrew/bin/herdr'
    # Custom shortcuts receive ACTIVE_PANE_ID; PANE_ID belongs to pane children.
    pane = os.environ['HERDR_ACTIVE_PANE_ID']
    result = subprocess.run([binary, 'pane', 'process-info', '--pane', pane],
                            check=True, capture_output=True, text=True, timeout=3)
    processes = json.loads(result.stdout)['result']['process_info']['foreground_processes']
    command = route(args.action, args.direction, processes, pane)
    subprocess.run([binary, 'pane', *command], check=True,
                   stdout=subprocess.DEVNULL, timeout=3)


if __name__ == '__main__':
    try:
        main()
    except (KeyError, ValueError, OSError, subprocess.SubprocessError) as error:
        print(f'Cannot control split: {error}', file=sys.stderr)
        sys.exit(1)
