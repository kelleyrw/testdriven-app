# testdriven

[![Build Status](https://travis-ci.org/kelleyrw/testdriven-app.svg?branch=master)](https://travis-ci.org/kelleyrw/testdriven-app)


## Install Docker 

### Mac:

(link slightly stale): [How to install Docker on Mac OS using brew?](https://pilsniak.com/how-to-install-docker-on-mac-os-using-brew/)

use these commands 

-- sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
-- sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

````
brew install docker docker-machine xhyve docker-machine-driver-xhvve gfortran
brew install formula/docker-compose.rb 
docker-machine create ags --virtualbox-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v18.09.6/boot2docker.iso
eval $(docker-machine env ags)
docker-machine start ags
docker-machine ls 
````

need to run the following each time you start a terminal (or source it bashrc):
````
eval $(docker-machine env ags)
````