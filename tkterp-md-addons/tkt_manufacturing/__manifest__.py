{
    'name': 'TKT Manufacturing',
    'version': '1.0',
    'category': 'Manufacturing',
    'summary': 'Manufacturing System for TKT',

    'depends': [
    'base',
    'mrp',
    'stock',
    'purchase',
    'sale_management',
    ],

    'data': [
        'security/security.xml',
        'security/ir.model.access.csv',

        'views/menu.xml',
        'views/mrp_production_views.xml',
    ],

    'installable': True,
    'application': True,
    'auto_install': False,
}