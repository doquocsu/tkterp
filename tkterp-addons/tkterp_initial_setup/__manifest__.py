{
    'name': 'TKTPlastic Initial Setup',
    'version': '1.0',
    'category': 'Sales',
    'summary': 'Initial company configuration for TKTPlastic',
    'depends': ['base', 'l10n_vn'],
    'assets': {
        'web.assets_backend': [
            'tkterp_initial_setup/static/src/scss/tkterp_theme.scss',
        ],
    },
    'post_init_hook': 'post_init_hook',
    'installable': True,
    'application': False,
    'auto_install': False,
}
