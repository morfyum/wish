sudo podman run -it --rm \
  --name samba \
  -p 445:445/tcp \
  -p 139:139/tcp \
  -p 137:137/udp \
  -p 138:138/udp \
  -e ACCOUNT_samba='SambaTest2026' \
  -e SAMBA_VOLUME_CONFIG_share='[share]; path = /shares/share; valid users = samba; read only = no; browseable = yes' \
  -v ../shared:/shares/share:Z \
  ghcr.io/servercontainers/samba:smbd-only-latest

# RUN AS DAEMON
# podman run -d
# --restart=unless-stopped
