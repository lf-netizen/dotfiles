#!/usr/bin/env python3
"""Focus the final local agent, or the most recent agent needing attention."""
import argparse
import json
import os
import subprocess
import sys


def last_agent(response):
    agents = response['result']['agents']
    return agents[-1]['pane_id'] if agents else None


def attention_agent(response):
    candidates = [agent for agent in response['result']['agents']
                  if agent['agent_status'] in ('blocked', 'done')
                  and not agent.get('focused', False)]
    if not candidates:
        return None
    return max(candidates, key=lambda agent: agent['state_change_seq'])['pane_id']


def main(attention=False):
    # Custom commands inherit the GUI server's PATH, not the pane's zsh PATH.
    # Herdr supplies its own executable; the fallback matches this repo's macOS setup.
    binary = os.environ.get('HERDR_BIN_PATH') or '/opt/homebrew/bin/herdr'
    response = subprocess.check_output([binary, 'agent', 'list'], text=True)
    select = attention_agent if attention else last_agent
    target = select(json.loads(response))
    if target:
        subprocess.run([binary, 'agent', 'focus', target], check=True,
                       stdout=subprocess.DEVNULL)


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--attention', action='store_true')
    args = parser.parse_args()
    try:
        main(attention=args.attention)
    except (subprocess.CalledProcessError, OSError, ValueError, KeyError) as error:
        print(f'Cannot focus Herdr agent: {error}', file=sys.stderr)
        sys.exit(1)
