FROM odoo:18.0
USER root
COPY entrypoint.sh /entrypoint-custom.sh
RUN chmod 755 /entrypoint-custom.sh
USER odoo
ENTRYPOINT ["/entrypoint-custom.sh"]
CMD ["odoo"]
