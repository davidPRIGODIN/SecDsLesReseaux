FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive

# Mettre à jour et installer les paquets
RUN apt update && apt install -y \
    apache2 ssl-cert iptables iptables-persistent iproute2 iputils-ping isc-dhcp-client dnsutils net-tools python3 && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*

# Activer les modules de Apache
RUN a2enmod ssl headers cgi

# Générer un certificat auto-signé et configurer https
RUN openssl genrsa -out server.key 2048 && \
    openssl req -new -key server.key -out server.csr -subj "/C=FR/ST=PACA/L=Nice/O=Polytech/CN=David" && \
    openssl x509 -req -days 900 -in server.csr -signkey server.key -out server.crt && \
    rm -f server.csr && \
    chmod 600 server.key server.crt && \
    chmod 700 /etc/ssl/private /etc/ssl/certs && \
    mv server.key /etc/ssl/private && \
    mv server.crt /etc/ssl/certs && \
    a2ensite default-ssl.conf && \
    sed -i \
    -e 's|^\s*SSLCertificateFile\s\+.*|SSLCertificateFile /etc/ssl/certs/server.crt|' \
    -e 's|^\s*SSLCertificateKeyFile\s\+.*|SSLCertificateKeyFile /etc/ssl/private/server.key|' \
    /etc/apache2/sites-available/default-ssl.conf && \
    rm -f /var/www/html/index.html

# Copier les fichiers index.html, scriptpass.pl, submit.py et modifier leurs permissions
COPY index.html /var/www/html/index.html
COPY scriptpass.pl /usr/lib/cgi-bin/scriptpass.pl
RUN chmod 644 /var/www/html/index.html && \
    chmod 755 /usr/lib/cgi-bin/scriptpass.pl

# Simuler attaque MIM
# Modifier default-ssl.conf, pour autoriser l'hôte à envoyer des requêtes POST
COPY submit.py /usr/lib/cgi-bin/submit.py
RUN chmod 755 /usr/lib/cgi-bin/submit.py
COPY add-default-ssl.conf /tmp/add-default-ssl.conf
RUN cat /tmp/add-default-ssl.conf >> /etc/apache2/sites-available/default-ssl.conf && rm /tmp/add-default-ssl.conf

# entrypoint
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

# Démarrer Apache en premier plan
CMD ["apache2ctl", "-D", "FOREGROUND"]