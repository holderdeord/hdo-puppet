# Loopback device:
auto lo
iface lo inet loopback

# device: eth0
auto  eth0
iface eth0 inet static
  address   46.4.88.198
  broadcast 46.4.88.223
  netmask   255.255.255.224
  gateway   46.4.88.193
  # default route to access subnet
  up route add -net 46.4.88.192 netmask 255.255.255.224 gw 46.4.88.193 eth0

#
# failover ip
#
auto eth0:1
iface eth0:1 inet static
  address   46.4.70.210
  broadcast 46.4.88.223
  netmask   255.255.255.224

iface eth0 inet6 static
  address 2a01:4f8:140:71c5::2
  netmask 64
  gateway fe80::1