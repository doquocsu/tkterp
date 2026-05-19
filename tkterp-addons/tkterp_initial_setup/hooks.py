import base64
import os


def post_init_hook(env):
    company = env.company
    company.name = 'Công ty TNHH TKTPlastic'

    vn = env.ref('base.vn')
    if vn:
        company.country_id = vn

    logo_path = os.path.join(os.path.dirname(__file__), 'data', 'tktplastic-logo.png')
    with open(logo_path, 'rb') as f:
        logo_data = base64.b64encode(f.read())
    company.logo = logo_data
    company.logo_web = logo_data

    vnd_currency = env['res.currency'].search([('name', '=', 'VND')], limit=1)
    if vnd_currency:
        company.write({'currency_id': vnd_currency.id})

    lang_code = 'vi_VN'
    lang = env['res.lang'].search([('code', '=', lang_code)], limit=1)
    if not lang:
        env['res.lang']._activate_lang(lang_code)
    company.partner_id.lang = lang_code
