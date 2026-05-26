{
    'name': 'TKTERP Custom Branding',
    'version': '18.0.1.0',
    'summary': 'Thay doi giao dien va mau sac he thong TKTERP',
    'category': 'Technical',
    'author': 'Do Quoc Su',
    'depends': ['base', 'web'],
    'data': [
        'views/login_templates.xml',
    ],
    'assets': {
        'web.assets_backend': [
            '/tkterp_branding/static/src/css/custom_style.css',
        ],
        'web.assets_frontend': [
            '/tkterp_branding/static/src/css/custom_style.css',
        ],
    },
    'installable': True,
    'application': False,
}
