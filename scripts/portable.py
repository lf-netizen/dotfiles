"""Keep local agent paths and Codex trust out of exported settings."""
import json
import re
from pathlib import Path


def codex_sections(data):
    public, local = [], []
    destination = public
    for line in data.decode().splitlines(keepends=True):
        header = re.match(r'^\s*\[([^\]]+)\]\s*$', line)
        if header:
            name = header[1]
            destination = local if (name == 'projects' or name.startswith('projects.')
                                    or name == 'hooks.state' or name.startswith('hooks.state.')) else public
        destination.append(line)
    return ''.join(public).rstrip().encode() + b'\n', ''.join(local).encode()


def portable(source, data):
    if source.parts[-3:] == ('agents', 'codex', 'config.toml'):
        return codex_sections(data)[0]
    if source.parts[-3:] not in (('agents', 'claude', 'settings.json'),
                                ('agents', 'codex', 'hooks.json')):
        return data
    settings = json.loads(data)
    home = str(Path.home())
    def rewrite(value):
        if isinstance(value, dict):
            return {key: rewrite(item) for key, item in value.items()}
        if isinstance(value, list):
            return [rewrite(item) for item in value]
        if isinstance(value, str):
            # Only shell command paths for this home; preserve other settings.
            value = re.sub(r"'" + re.escape(home) + r"(/[^']*)'",
                           lambda m: '"$HOME' + m[1] + '"', value)
            value = re.sub(re.escape(home) + r'(/[^\s"\']+)',
                           lambda m: '"$HOME' + m[1] + '"', value)
        return value
    return (json.dumps(rewrite(settings), indent=2) + '\n').encode()


def deployment_bytes(source, target):
    data = portable(source, source.read_bytes())
    if source.parts[-3:] == ('agents', 'codex', 'config.toml') and target.is_file():
        data += b'\n' + codex_sections(target.read_bytes())[1]
    return data
