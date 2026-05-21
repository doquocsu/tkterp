"""Set admin user password using pbkdf2_sha512 (Odoo 19 format)."""
import os
import psycopg2
from passlib.context import CryptContext

ctx = CryptContext(schemes=['pbkdf2_sha512'])
password = os.environ.get('ADMIN_PASSWORD', 'devadmin')
hash_ = ctx.hash(password)

conn = psycopg2.connect(
    host='tkterp-db', dbname='tkterp',
    user='odoo', password=os.environ['PASSWORD']
)
cur = conn.cursor()
cur.execute('UPDATE res_users SET password = %s WHERE login = %s', (hash_, 'admin'))
conn.commit()
cur.close()
conn.close()
print(f'Admin password updated ({len(password)} chars, pbkdf2_sha512)')
