#!/bin/bash

# Python/Flask dependencies
pip install virtualenv virtualenvwrapper autoenv

# Setup the virtual environments
mkdir $HOME/.virtualenv
mkdir /home/nanny/.virtualenv
chown nanny.www-data /home/nanny/.virtualenv
export WORKON_HOME=$HOME/.virtualenv
source /usr/local/bin/virtualenvwrapper.sh
source /usr/local/bin/activate.sh

# TODO figure out how to automate making the virtualenvs
#su -c "mkvirtualenv website" nanny
#su -c "mkvirtualenv api" nanny
