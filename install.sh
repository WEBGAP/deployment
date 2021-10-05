#!/bin/sh

IMAGE_PATH=images
firstInstall() {
    sudo mkdir -p /var/safeweb/certs
    sudo cp -r ./certs/* /var/safeweb/certs/
    sudo cp daemon.json /etc/docker/
    sudo mkdir -p /etc/systemd/system/docker.service.d
    sudo cp startup_options.conf /etc/systemd/system/docker.service.d/
    sudo systemctl daemon-reload
    sudo systemctl restart docker.service
    #sudo mkdir -p /upload
    #sudo mkdir -p /usr/attackLog
}

run_process() {
    #sed "s/safweb_branch/$branch/g" app.yml > app_new.yml
    docker tag safeweb-browser webmirror:v1
    docker-compose -f app.yml up -d
}

get() {
    docker pull 192.168.50.123:5000/safeweb-app:$branch
    docker pull 192.168.50.123:5000/mysql:5.7.25
    docker pull 192.168.50.123:5000/safeweb-browser:$branch
    docker pull 192.168.50.123:5000/safeweb-client:$branch
}

save_images() {
    mkdir -p ./$IMAGE_PATH
    docker save safeweb-app > $IMAGE_PATH/safeweb-app.tar
    docker save mysql:5.7.25 > $IMAGE_PATH/mysql.tar
    docker save safeweb-browser > $IMAGE_PATH/safeweb-browser.tar
    docker save safeweb-client > $IMAGE_PATH/safeweb-client.tar
    #docker save 192.168.50.123:5000/wais-admin:master > $IMAGE_PATH/wais-admin.tar
    #docker save 192.168.50.123:5000/wais-client:master > $IMAGE_PATH/wais-client.tar
}

load_images() {
    docker load < $IMAGE_PATH/safeweb-app.tar
    docker load < $IMAGE_PATH/mysql.tar
    docker load < $IMAGE_PATH/safeweb-browser.tar
    docker load < $IMAGE_PATH/safeweb-client.tar
    #docker load < $IMAGE_PATH/wais-admin.tar
    #docker load < $IMAGE_PATH/wais-client.tar
}

action=$1

if [[ "$action" == "install" ]]; then
    systemctl stop firewalld
    systemctl restart docker.service
    firstInstall
    load_images
    run_process

elif [[ "$action" == "package" ]]; then
    #get
    save_images

elif [[ "$action" == "update" ]]; then
    load_images
    run_process

elif [[ "$action" == "run" ]]; then
    run_process
fi


