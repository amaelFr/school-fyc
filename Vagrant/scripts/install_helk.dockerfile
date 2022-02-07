sudo su
apt update && apt upgrade -y

apt remove docker docker-engine docker.io -y
apt install curl apt-transport-https ca-certificates software-properties-common -y
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu  $(lsb_release -cs)  stable"
apt update
apt install docker-ce -y

systemctl enable docker
systemctl start docker

apt install git python3-pip -y
python3 -m pip install --upgrade pip
pip install docker-compose

git clone https://github.com/Cyb3rWard0g/HELK
cd HELK/docker
./helk_install.sh



docker run --rm -it\
  --volume docker_esdata:/tmp/data \
  --volume $(pwd):/tmp/backup \
  ubuntu bash


## backup
docker-compose -f helk-kibana-notebook-analysis-basic.yml stop
docker-compose -f helk-kibana-notebook-analysis-basic.yml down
docker run --rm \
  --volume docker_esdata:/tmp/data \
  --volume $(pwd):/tmp/backup \
  ubuntu \
  tar cvf /tmp/backup/esdata.tar /tmp/data

## restore
docker run --rm \
  --volume docker_esdata:/tmp/data \
  --volume $(pwd):/tmp/backup \
  ubuntu \
  sh -c 'tar xvf /tmp/backup/esdata.tar -C /tmp --strip 1 && chown -R 1000:0 /tmp/data/*'