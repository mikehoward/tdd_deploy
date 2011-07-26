#! /bin/sh



# add user key to ~root/.ssh/authorized_keys
scp ~/.ssh/id_rsa.pub root

# edit /etc/ssh/sshd_config
    
    PermitRootLogin yes

/etc/rc.d/sshd restart  # arch linux
service ssh restart     # ubuntu linux

#    Test ssh root@hostname to make sure it works, then change
    PermitRootLogin without-password
