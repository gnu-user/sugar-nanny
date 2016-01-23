#!/bin/bash
USER="$1"

useradd -mN -g www-data -s /bin/bash ${USER}
cp -vrf ../config/.ssh /home/${USER}/
chown ${USER}.www-data -R /home/${USER}/.ssh
chmod 0600 /home/${USER}/.ssh/id_rsa
chmod 0644 /home/${USER}/.ssh/id_rsa.pub
cp -vf ../config/.gitconfig /home/${USER}/
cp -vf ../config/.emacs /home/${USER}/
cp -vf ../config/vimrc /home/${USER}/
cp -vf ../config/.screenrc /home/${USER}/
cp -vf ../config/.bashrc /home/${USER}/
# Change the colour of the shell prompt
sed -i -e 's|33\[01;31m|33\[01;35m|g' /home/${USER}/.bashrc
# Change ownership of config files
chown ${USER}.www-data /home/${USER}/*
