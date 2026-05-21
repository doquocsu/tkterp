"""Set company logo from image file."""

import base64
import os

import psycopg2

logo_path = '/mnt/extra-addons/tkterp_base/static/tktplastic-logo.png'

conn = psycopg2.connect(
    host='tkterp-db', dbname='tkterp', user='odoo', password=os.environ['PASSWORD']
)
cur = conn.cursor()

cur.execute('SELECT partner_id FROM res_company WHERE id = 1')
partner_id = cur.fetchone()[0]

with open(logo_path, 'rb') as f:
    raw = f.read()
    b64 = base64.b64encode(raw).decode()

cur.execute(
    "UPDATE ir_attachment SET db_datas = %s, mimetype = 'image/png', write_date = NOW() "
    "WHERE res_model = 'res.partner' AND res_field = 'image_1920' AND res_id = %s",
    (psycopg2.Binary(raw), partner_id),
)
cur.execute('UPDATE res_company SET logo_web = %s WHERE id = 1', (b64,))

conn.commit()
cur.close()
conn.close()
print(f'Company logo set ({len(raw)} bytes)')
