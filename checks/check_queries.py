"""Synthetic relational checks using SQLite, not a replacement for MySQL dialect tests."""
import re,sqlite3
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
c=sqlite3.connect(':memory:')
schema=(ROOT/'sql/schema.sql').read_text()
for name,body in re.findall(r'CREATE TABLE `([^`]+)` \((.*?)\) ENGINE=',schema,re.S):
    cols=re.findall(r'^  `([^`]+)`\s+(\w+)',body,re.M)
    c.execute('CREATE TABLE "'+name+'" ('+','.join('"'+n+'" '+('INTEGER' if t in ('int','year') else 'REAL' if t=='float' else 'TEXT') for n,t in cols)+')')
def insert(table,columns,rows):
    c.executemany('INSERT INTO '+table+' ('+','.join(columns.split())+') VALUES ('+','.join('?' for _ in columns.split())+')',rows)
insert('company','abn company_name parent_abn',[('1','Root',None),('2','Child','1'),('3','Grandchild','2'),('4','Other',None)])
insert('person','license_num person_name',[('p1','Alice'),('p2','Bob'),('p3','Cara')])
insert('electric_vehicle','vin abn license_num model_name model_year battery_capacity',[('v1','1','p1','M1',2024,100),('v2','2','p2','M2',2024,100),('v3','3','p3','M3',2023,60),('v4','4','p1','M4',2022,40),('v5','1','p1','M5',2024,90)])
insert('charging_station','station_id street state postcode',[(1,'125 Collins Street','VIC','3000'),(2,'Example','VIC','3500'),(3,'Boundary','VIC','4000')])
insert('outlet','outlet_number station_id charging_rate price_kwh',[(1,1,100,.4),(2,1,120,.5),(1,2,69,.6),(1,3,68,.2)])
insert('company_owns_station','abn station_id',[('1',1),('1',2),('4',3)])
insert('facility','facility_id station_id',[(1,1),(2,2),(3,2)])
insert('coupon','coupon_id facility_id discount',[(1,1,.5),(2,2,.8),(3,1,.9)])
insert('charging_event','charge_event_id requested_at vin license_num station_id outlet_number coupon_id kwh',[
(1,'2025-01-01 12:00:00','v1','p1',1,1,1,40),
(2,'2025-01-02 12:00:00','v1','p1',1,2,None,80),
(3,'2025-01-03 12:00:00','v1','p1',2,1,None,60),
(4,'2025-01-03 12:00:00','v2','p1',1,2,2,20),
(5,'2025-01-04 12:00:00','v2','p3',1,1,None,None),
(6,'2025-02-01 00:00:00','v3','p3',1,2,None,30),
(7,'2025-01-01 00:00:00','v4','p2',3,1,None,50),
(8,'2025-01-01 09:00:00','v3','p2',1,2,3,10)])
queries=re.split(r'-- Q\d+:', (ROOT/'sql/reviewed_queries.sql').read_text())[1:]
expected=[{('M1',2024,100),('M2',2024,100)},{(1,'VIC','3000')},{(3,)},{('p1','Alice',1)},{(2,)},{('M1',2024,'Root',60.0)},{(4,)},{('v2',),('v4',)},{('p1','v1'),('p1','v2'),('p3','v2'),('p3','v3'),('p2','v3'),('p2','v4')},{(52.5,)}]
for i,(q,want) in enumerate(zip(queries,expected),1):
    # The introductory business description follows the Q marker on the same line.
    sql=q[q.index('\n')+1:]
    got=set(c.execute(sql).fetchall());assert got==want,(i,got,want)
assert len(queries)==10
print('10/10 synthetic query checks passed: ties, threshold=100, full day, NULL energy, owner exclusion, hierarchy, universal coverage, postcode boundary, discounts and month boundary.')
