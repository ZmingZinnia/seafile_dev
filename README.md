# README.md

## includes mode

* seafile-pro-server
* ccnet-pro-server
* seahub
* seahub-extra
* seafevents
* seafobj

## file struct

* mounted directory
  * conf:configure folder
  * dev: the code of seafile-pro etc project
  * logs: the logs of project
  * migrate
    * source
      * bin: the binary file of compile
      * include: the head file of compile
      * lib: the lib file of compile
      * share: the share data of compile

## Usage

### Steps

* download `docker-compose.yml` file

    ```bash
    cd /tmp
    wget https://raw.githubusercontent.com/seafileltd/seafile_dev/master/docker-compose.yml
    ```

* create the mounted directory and create the `ssh_key` folder in that directory, copy public/private key to `ssh_key` folder

    ```bash
    mkdir -p /data
    mkdir -p /data/ssh_key
    cp ~/.ssh/id_rsa* /data/ssh_key
    ```

* update docker-compose.yml

    ```yml
    ...
    ...
    # the path of mysql data mounted, update `/opt/mysql-data` to any path you want to save
    /opt/mysql-data:/var/lib/mysql
    ...
    ...
    # the path of this project mounted, update `/root/data` to any path you want to save
    /root/data:/data
    ...
    ```

* login private register

* run image

    ```bash
    cd /tmp
    docker-compose up
    ```

* wait for compilation to complete

* create seahub table

    ```bash
    docker exec -it seafile-dev-pro /root/seafile/dev/run.sh python-env /root/seafile/dev/seahub/manage.py syncdb
    ```

* create super admin

    ```bash
    docker exec -it seafile-dev-pro /root/seafile/dev/run.sh python-env /root/seafile/dev/seahub/manage.py createsuperuser
    ```

## explain

* ssh private/public key

    used to pub the code to seafileltd organization

* image

    contains the package installed by apt/pip

* start image

    compile project if is new volumes[this will cost a lot of time]

## other command

* exec python command under project env

    ```bash
    docker exec -it seafile-dev-pro /root/seafile/dev/run.sh.sh python-env xxx
    equal to `python xxx`
    ```

* migrate the file of compilation to `/usr` path

    ```bash
    docker exec -it seafile-dev-pro /root/seafile/dev/run.sh.sh migrate
    ```

## simple example

### switch bottom branch

    ```bash
    # enter continer
    docker exec -it /root/scripts/seafile-checkout.sh ccnet-pro-server[project_name] 6.3-pro[branch_name]
    ```