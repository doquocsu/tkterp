"""Set company currency to VND."""
import os
import psycopg2

conn = psycopg2.connect(
    host='tkterp-db', dbname='tkterp',
    user='odoo', password=os.environ['PASSWORD']
)
cur = conn.cursor()
cur.execute(
    "UPDATE res_company SET currency_id = (SELECT id FROM res_currency WHERE name = 'VND') WHERE id = 1"
)
conn.commit()
cur.close()
conn.close()
print('Company currency set to VND')
