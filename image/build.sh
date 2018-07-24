image_name=docker-dev.seafile.top/seafile-pro-dev:master
suqash_image_name=docker-dev.seafile.top/seafile-pro-dev:master-squash
docker build -t $image_name .
docker-squash --tag $suqash_image_name $image_name
docker tag $suqash_image_name $image_namedocker 
