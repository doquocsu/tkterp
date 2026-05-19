{
    'name': 'TKTPlastic Base',
    'version': '1.0',
    'category': 'Sales',
    'summary': 'Base module for TKTPlastic customizations',
    'depends': ['base'],
    'data': [
        'security/ir.model.access.csv',
    ],
    'assets': {
        'web.assets_backend': [
            'tkterp_base/static/src/scss/tkterp_base.scss',
        ],
    },
    'installable': True,
    'application': False,
    'auto_install': False,
}
