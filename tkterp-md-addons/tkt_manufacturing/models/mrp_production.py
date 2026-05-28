from odoo import models, fields


class MrpProduction(models.Model):
    _inherit = 'mrp.production'

    tkt_note = fields.Text(
        string='Ghi chú TKT'
    )

    qc_status = fields.Selection([
        ('draft', 'Chờ QC'),
        ('pass', 'Đạt'),
        ('fail', 'Không đạt'),
    ], string='QC Status')

    machine_code = fields.Char(
        string='Mã Máy'
    )