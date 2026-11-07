"""Rebuild SQLite databases from committed CSV files and execute analytical SQL."""
import argparse
import csv
from pathlib import Path
import sqlite3

ROOT = Path(__file__).resolve().parents[1]
PROJECTS = ('01-shop', '02-funnel', '03-service')


def run(name):
    project = ROOT / name
    # Build in memory first so a failed import cannot damage the saved database.
    con = sqlite3.connect(':memory:')
    con.execute('PRAGMA foreign_keys = ON')
    con.executescript((project / 'sql' / 'schema.sql').read_text())
    tables = [row[0] for row in con.execute(
        "SELECT name FROM sqlite_master WHERE type='table' ORDER BY rowid"
    )]
    for table in tables:
        with (project / 'data' / f'{table}.csv').open(encoding='utf-8', newline='') as f:
            reader = csv.reader(f)
            columns = next(reader)
            actual = [r[1] for r in con.execute(f'PRAGMA table_info("{table}")')]
            if columns != actual:
                raise ValueError(f'{name}/{table}: unexpected CSV columns')
            # Empty fields represent NULL; this convention is documented in README.
            rows = [[None if value == '' else value for value in row] for row in reader]
            placeholders = ','.join('?' for _ in columns)
            con.executemany(f'INSERT INTO "{table}" VALUES ({placeholders})', rows)
    con.commit()
    assert con.execute('PRAGMA integrity_check').fetchone()[0] == 'ok'
    assert not con.execute('PRAGMA foreign_key_check').fetchall()
    for sql_file in sorted((project / 'sql').glob('[0-9][0-9]_*.sql')):
        cursor = con.execute(sql_file.read_text())
        rows = cursor.fetchall()
        output = project / 'results' / (sql_file.stem[3:] + '.csv')
        with output.open('w', encoding='utf-8-sig', newline='') as f:
            writer = csv.writer(f)
            writer.writerow([col[0] for col in cursor.description])
            writer.writerows(rows)
        print(f'{name}: {sql_file.name} -> {len(rows)} rows')
    with sqlite3.connect(project / 'project.sqlite') as target:
        con.backup(target)
    con.close()


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--project', choices=PROJECTS, help='Run only one case')
    args = parser.parse_args()
    for name in (args.project,) if args.project else PROJECTS:
        run(name)
