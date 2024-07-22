#!/bin/sh
#
getent passwd |
    while IFS=: read -r username x uid gid gecos home shell
    do
        if [ ! -d "$home" ] || [ "$username" == 'root' ] || [ "$uid" -lt 1000 ]
        then
            continue
        fi
        echo  -e "======================== \033[37;1;1m$username\033[0m ========================"
        tar -cf - -C /etc/skel . | sudo -Hiu "$username" tar --skip-old-files --strip-components=1 -xf -
    done
