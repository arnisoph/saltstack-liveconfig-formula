liveconfig:
  lookup:
    server:
      config:
        liveconfig:
          sections:
            - name: General settings
              user: liveconfig
              group: liveconfig
            - name: Database settings
              db_driver: sqlite
              db_name: /var/lib/liveconfig/liveconfig.db
            - name: HTTP protocol settings
              http_ssl_certificate: /etc/liveconfig/sslcert.pem
              http_redirect:
                - 301  /               /liveconfig/login
                - 301  /liveconfig     /liveconfig/login
              http_rewrite: /robots.txt          /res/m/liveconfig/robots.txt
            - name: LCCP protocol settings
              lccp_socket: '*:788'
      sqlite_db:
        ensure: managed
