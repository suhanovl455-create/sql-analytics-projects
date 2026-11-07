"""Independent checks: compare SQL reports with Python calculations on source rows."""
import csv, sqlite3
from pathlib import Path
from collections import defaultdict, Counter
from datetime import datetime, timedelta
ROOT=Path(__file__).resolve().parents[1]
def report(folder,name):
    with (ROOT/folder/'results'/f'{name}.csv').open(encoding='utf-8-sig') as f:
        return list(csv.DictReader(f))
db=sqlite3.connect(ROOT/'01-shop'/'project.sqlite')
source=db.execute("SELECT o.order_id,o.order_date,i.quantity,i.unit_price_kopecks FROM orders o JOIN order_items i USING(order_id) WHERE o.status='paid'").fetchall()
totals=defaultdict(int); ids=defaultdict(set)
for oid,day,qty,price in source:
    totals[day[:7]]+=qty*price; ids[day[:7]].add(oid)
for row in report('01-shop','monthly'):
    month=row['month']
    assert float(row['revenue_rub'])==totals[month]/100
    assert int(row['paid_orders'])==len(ids[month])
    assert abs(float(row['avg_order_rub'])-totals[month]/100/len(ids[month]))<=.0051
assert round(sum(float(r['revenue_rub']) for r in report('01-shop','categories'))*100)==sum(totals.values())
counts=Counter(x[0] for x in db.execute("SELECT customer_id FROM orders WHERE status='paid'"))
r=report('01-shop','repeat')[0]
assert int(r['paying_customers'])==len(counts)
assert int(r['repeat_customers'])==sum(n>=2 for n in counts.values())
db.close()

db=sqlite3.connect(ROOT/'02-funnel'/'project.sqlite')
ev=defaultdict(lambda:defaultdict(list))
for uid,name,stamp in db.execute('SELECT user_id,event_name,event_time FROM events'):
    ev[uid][name].append(datetime.fromisoformat(stamp))
expected=defaultdict(lambda:[0,0,0])
for uid,channel in db.execute('SELECT user_id,channel FROM users'):
    start=min(ev[uid]['signup']); end=start+timedelta(days=7)
    expected[channel][0]+=1
    verified=[t for t in ev[uid]['verify'] if start<=t<=end]
    if verified:
        expected[channel][1]+=1
        if any(min(verified)<=t<=end for t in ev[uid]['activate']): expected[channel][2]+=1
for r in report('02-funnel','funnel'):
    assert [int(r[k]) for k in ('signups','verified','activated')]==expected[r['channel']]
db.close()

db=sqlite3.connect(ROOT/'03-service'/'project.sqlite')
cutoff=datetime(2026,10,31,23,59,59)
closed=defaultdict(list); opened=Counter(); overdue=Counter()
for team,created,finished in db.execute('SELECT t.name,k.created_at,k.closed_at FROM tickets k JOIN teams t USING(team_id)'):
    start=datetime.fromisoformat(created)
    end=datetime.fromisoformat(finished) if finished else None
    if end and end<=cutoff: closed[team].append((end-start).total_seconds()/3600)
    elif start<=cutoff:
        opened[team]+=1
        overdue[team]+=start+timedelta(hours=24)<cutoff
for r in report('03-service','sla'):
    values=closed[r['name']]
    assert int(r['closed_tickets'])==len(values)
    assert int(r['within_sla'])==sum(v<=24 for v in values)
    assert abs(float(r['avg_resolution_hours'])-sum(values)/len(values))<=.0051
for r in report('03-service','backlog'):
    assert int(r['open_tickets'])==opened[r['name']]
    assert int(r['overdue_tickets'])==overdue[r['name']]
assert sum(map(len,closed.values()))+sum(opened.values())==150
db.close()
print('PASS: revenue, order counts, average check, repeat buyers, sequential funnel, SLA, backlog, and ticket reconciliation.')
