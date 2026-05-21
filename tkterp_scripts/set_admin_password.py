"""Set admin user password using pbkdf2_sha512 (Odoo 18 format)."""

import os

import passlib.context
import psycopg2

ctx = passlib.context.CryptContext(schemes=['pbkdf2_sha512'])
password = os.environ['ADMIN_PASSWORD']
hash_ = ctx.hash(password)

conn = psycopg2.connect(
    host='tkterp-db',
    dbname='tkterp',
    user='odoo',
    password=os.environ['PASSWORD'],
)
cur = conn.cursor()
cur.execute('UPDATE res_users SET password = %s WHERE login = %s', (hash_, 'admin'))
conn.commit()
cur.close()
conn.close()
print(f'Admin password updated ({len(password)} chars, pbkdf2_sha512)')  # noqa: T201
