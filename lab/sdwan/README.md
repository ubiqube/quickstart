# [Sandbox] SDWAN LAB

Sandbox environment intended to be base environment for further development:
  - site_A - HUB (headquarter)
  - site_B - branch (remote office)
  - site_C - branch (remote office)
  - site_N - scalig-out (remote office)
  - underlay network: 172.20.0.0/24 - eth0 interfaces
  - overlay network: IPsec

## Diagram - underlay netwotk

                                   +---------------------+
                                   |site_A               |
                                   |lo0:  192.168.55.1/32|
                                   |eth0: 172.20.0.121/24|
                                   +----------+----------+
                                              |                          172.20.0.0/24
       +-------+-------------------------------------------------------------+-------+
               |                              |                              |
    +----------+----------+        +----------+----------+        +----------+----------+
    |site_B               |        |site_C               |        |site_N               |
    |lo0:  192.168.55.2/32|        |lo0:  192.168.55.3/32|        |lo0:  192.168.55.x/32|
    |eth0: 172.20.0.122/24|        |eth0: 172.20.0.123/24|        |eth0: x.x.x.x/x      |
    +---------------------+        +---------------------+        +---------------------+


## Diagram - IPsec - overlay network


                                   +---------------------+
                                   |site_A               |
               +------------------>+lo0:  192.168.55.1/32+<------------------+
               |                   |eth0: 172.20.0.121/24|                   |
               |                   +----------+----------+                   |
               |                              ^                              |
               |                              |                              |
               |                              |                              |
    +----------+----------+        +----------+----------+        +----------+----------+
    |site_B               |        |site_C               |        |site_N               |
    |lo0:  192.168.55.2/32|        |lo0:  192.168.55.3/32|        |lo0:  192.168.55.x/32|
    |eth0: 172.20.0.122/24|        |eth0: 172.20.0.123/24|        |eth0: x.x.x.x/x      |
    +---------------------+        +---------------------+        +---------------------+



## Site_A (HUB) configuration

**Login to machine**
```sh
$ ssh root@172.20.0.121
```

**Configure Loopback IP address - local=left network:**
```sh
# ifconfig lo:0 192.168.55.1 netmask 255.255.255.255 up
```

**IPsec configuration**
/etc/ipsec.conf
```js
conn %default                                         
      ikelifetime=1440m                               
      keylife=60m                                     
      rekeymargin=3m                                  
      keyingtries=1                                   
      keyexchange=ikev1                               
      authby=secret                                   
                                                      
conn a_b                                              
      left=172.20.0.121                               
      leftsubnet=192.168.55.1/32                      
      leftid=172.20.0.121                             
      leftfirewall=yes                                
      right=172.20.0.122                              
      rightsubnet=192.168.55.2/32                     
      rightid=172.20.0.122                            
      auto=start                                      
      ike=aes128-md5-modp1536                         
      esp=aes128-sha1            
                                 
conn a_c                         
      left=172.20.0.121          
      leftsubnet=192.168.55.1/32 
      leftid=172.20.0.121        
      leftfirewall=yes           
      right=172.20.0.123         
      rightsubnet=192.168.55.3/32
      rightid=172.20.0.123       
      auto=start                 
      ike=aes128-md5-modp1536    
      esp=aes128-sha             
                                 
conn b_to_site                   
     also=a_b                    
     leftsubnet=192.168.55.0/24  

conn c_to_site
     also=a_c  
     leftsubnet=192.168.55.0/24
```

**IPsec secretes**
/etc/ipsec.secrets
```js
172.20.0.122 172.20.0.121 : PSK passw0rd
172.20.0.123 172.20.0.121 : PSK passw0rd
```

**Run IPsec**
```sh
# ipsec start
```
## Site_B (Branch) configuration

**Login to machine**
```sh
$ ssh root@172.20.0.122
```
**Configure Loopback IP address - local=left network:**
```sh
# ifconfig lo:0 192.168.55.2 netmask 255.255.255.255 up
```

**IPsec configuration**
/etc/ipsec.conf
```js
conn %default                                         
      ikelifetime=1440m                               
      keylife=60m      
      rekeymargin=3m   
      keyingtries=1    
      keyexchange=ikev1
      authby=secret    
                       
conn b_a_hub           
      left=172.20.0.122
      leftsubnet=192.168.55.2/32
      leftid=172.20.0.122       
      leftfirewall=yes          
      right=172.20.0.121        
      rightsubnet=192.168.55.1/32
      rightid=172.20.0.121       
      auto=start                 
      ike=aes128-md5-modp1536    
      esp=aes128-sha1            
                             
conn b_a_sites               
      also=b_a_hub           
      rightsubnet=192.168.55.0/24
```

**IPsec secrets**
/etc/ipsec.secrets
```js
172.20.0.122 172.20.0.121 : PSK passw0rd
```

**Run IPsec**
```sh
# ipsec start
```

## Site_C (Branch) configuration

**Login to machine**
```sh
$ ssh root@172.20.0.122
```

**Configure Loopback IP address - local=left network:**
```sh
# ifconfig lo:0 192.168.55.3 netmask 255.255.255.255 up
```

**IPsec configuration**
/etc/ipsec.conf
```js
conn %default                                         
      ikelifetime=1440m                               
      keylife=60m      
      rekeymargin=3m   
      keyingtries=1    
      keyexchange=ikev1
      authby=secret    
                       
conn c_a_hub           
      left=172.20.0.123
      leftsubnet=192.168.55.3/32
      leftid=172.20.0.123       
      leftfirewall=yes          
      right=172.20.0.121        
      rightsubnet=192.168.55.1/32
      rightid=172.20.0.121       
      auto=start                 
      ike=aes128-md5-modp1536    
      esp=aes128-sha1            
                             
conn c_b_sites               
      also=c_a_hub           
      rightsubnet=192.168.55.0/24
```

**IPsec secrets**
/etc/ipsec.secrets
```js
172.20.0.123 172.20.0.121 : PSK passw0rd
```

**Run IPsec**
```sh
# ipsec start
```

## Verify 
**Commands to run on any machine**

Check the status
```sh
# ipsec status
```
More details
```sh
# ipsec statusall
```
Check encryption domain routes
```sh
# show ip route table 220
```
