function func_nginx_cfg {
  cat <<EOF > /etc/nginx/sites-available/$HOST_NAME
server {
    listen $EXT_IP_ADDR:$NGINX_PORT;
    server_name vm1;
    ssl_certificate           $SSL_PATH/web.pem;
    ssl_certificate_key       $SSL_PATH/web.key;
    ssl on;
    ssl_session_cache  builtin:1000  shared:SSL:10m;
    ssl_protocols  TLSv1 TLSv1.1 TLSv1.2;
    ssl_ciphers HIGH:!aNULL:!eNULL:!EXPORT:!CAMELLIA:!DES:!MD5:!PSK:!RC4;
    ssl_prefer_server_ciphers on;
    access_log            /var/log/nginx/vm1.access.log;
    location / {
      proxy_set_header        Host \$host;
      proxy_set_header        X-Real-IP \$remote_addr;
      proxy_set_header        X-Forwarded-For \$proxy_add_x_forwarded_for;
      proxy_set_header        X-Forwarded-Proto \$scheme;
      # Fix the "It appears that your reverse proxy set up is broken" error.
      proxy_pass          http://$APACHE_VLAN_IP:80;
    }
}
  EOF
}
