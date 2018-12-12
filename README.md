# testdriven

## Install Docker 

### Mac:

(link slightly stale): [How to install Docker on Mac OS using brew?](https://pilsniak.com/how-to-install-docker-on-mac-os-using-brew/)

use these commands 

````
brew install docker docker-machine xhyve docker-machine-driver-xhvve gfortran
brew install formula/docker-compose.rb 
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
docker-machine create default --driver xhyve --xhyve-experimental-nfs-share --xhyve-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v18.06.1-ce/boot2docker.iso
eval $(docker-machine env default)
docker-machine start default
````

need to run the following each time you start a terminal (or source it bashrc):
````
eval $(docker-machine env default)
````
