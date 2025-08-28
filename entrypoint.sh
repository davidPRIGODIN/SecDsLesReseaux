#!/bin/bash
set -e

# Supprimer l'IP que Docker attribue
ip addr flush dev eth0

# Demander une nouvelle IP à pfSense via DHCP
dhclient eth0

# Message de démarrage envoyé aux logs Docker
echo "Démarrage de Apache …"

# Exécuter le CMD
exec "$@"

