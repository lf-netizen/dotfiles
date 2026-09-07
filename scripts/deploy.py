#!/usr/bin/env python3
"""Explicit deployment with private backups; no shell evaluation of the manifest."""
import argparse
import datetime
import json
import os
from pathlib import Path
import shutil
import sys
import hashlib
from portable import portable, deployment_bytes

ROOT = Path(__file__).resolve().parent.parent
HOME = Path.home().resolve()

def rows(group):
    result = []
    for line in (ROOT / 'symlinks.conf').read_text().splitlines():
        if not line.strip() or line.startswith('#'):
            continue
        mode, slice_name, src, dst = line.split('|')
        if group != 'all' and group != slice_name:
            continue
        assert mode in ('link', 'copy')
        assert not Path(src).is_absolute() and not Path(dst).is_absolute()
        assert '..' not in Path(src).parts + Path(dst).parts
        source, target = ROOT / src, HOME / dst
        assert source.exists(), f'Missing source: {source}'
        assert source.resolve().is_relative_to(ROOT), f'External source: {source}'
        assert target.parent.resolve().is_relative_to(HOME)
        assert source != target and not target.is_relative_to(ROOT)
        if target.is_symlink() and target.resolve() != source.resolve():
            raise RuntimeError(f'Refusing unrelated symlink: {target}')
        result.append((mode, source, target))
    if not result:
        raise RuntimeError('No matching manifest entries')
    return result

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('action', choices=['preview', 'apply', 'export', 'rollback'])
    parser.add_argument('--slice', default='all', choices=['all', 'shell', 'terminal', 'preserved', 'agents', 'vscode'])
    parser.add_argument('--record', type=Path, help='Exact deployment JSON for rollback')
    args = parser.parse_args()
    if args.action == 'rollback':
        if not args.record:
            parser.error('rollback requires --record')
        record = json.loads(args.record.read_text())
        # Validate every target before reverting any of them.
        for item in record:
            source, target = Path(item['source']), Path(item['target'])
            assert source.is_relative_to(ROOT) and target.is_relative_to(HOME) and target != HOME
            if item['mode'] == 'link':
                assert target.is_symlink() and target.resolve() == source.resolve(), f'Changed target: {target}'
            else:
                assert target.is_file() and not target.is_symlink(), f'Changed copy: {target}'
                unchanged = (hashlib.sha256(target.read_bytes()).hexdigest() == item['sha256']
                             if 'sha256' in item else target.read_bytes() == source.read_bytes())
                assert unchanged, f'Changed copy: {target}'
            if item['backup']:
                assert Path(item['backup']).exists() or Path(item['backup']).is_symlink()
        for item in reversed(record):
            target = Path(item['target'])
            target.unlink()  # only validated managed link or unchanged copied file
            if item['backup']:
                shutil.move(item['backup'], target)
        print('Restored deployment:', args.record)
        return

    entries = rows(args.slice)
    record = []
    backup = HOME / '.local/state/dotfiles-backups' / ('deploy-' + datetime.datetime.now().strftime('%Y%m%d-%H%M%S-%f'))
    if args.action in ('apply', 'export'):
        backup.mkdir(parents=True, mode=0o700)
    for mode, source, target in entries:
        correct = (mode == 'link' and target.is_symlink() and target.resolve() == source.resolve()) or (mode == 'copy' and target.is_file() and not target.is_symlink() and portable(source, target.read_bytes()) == portable(source, source.read_bytes()))
        print(f'{"OK" if correct else mode.upper()}: {source.relative_to(ROOT)} -> {target}')
        if args.action == 'preview' or correct:
            continue
        if args.action == 'export':
            if mode == 'copy':
                assert target.is_file() and not target.is_symlink()
                saved = backup / source.relative_to(ROOT)
                saved.parent.mkdir(parents=True, exist_ok=True)
                shutil.copy2(source, saved)
                source.write_bytes(portable(source, target.read_bytes()))
            continue
        content = deployment_bytes(source, target) if mode == 'copy' else None
        saved = None
        if target.exists() or target.is_symlink():
            saved = backup / 'home' / target.relative_to(HOME)
            saved.parent.mkdir(parents=True, exist_ok=True)
            shutil.move(target, saved)
        target.parent.mkdir(parents=True, exist_ok=True)
        item = {'mode': mode, 'source': str(source), 'target': str(target), 'backup': str(saved) if saved else None}
        if content is not None:
            item['sha256'] = hashlib.sha256(content).hexdigest()
        record.append(item)
        # Journal before creating the new target so partial failure is inspectable.
        (backup / 'deployment.json').write_text(json.dumps(record, indent=2) + '\n')
        if mode == 'link':
            target.symlink_to(source, target_is_directory=source.is_dir())
        else:
            target.write_bytes(content)
    if record:
        print('Rollback record:', backup / 'deployment.json')

if __name__ == '__main__':
    try:
        main()
    except (AssertionError, RuntimeError, OSError) as error:
        sys.exit(str(error))
