image_name=docker-dev.seafile.top/seafile-pro-dev:6.3
suqash_image_name=docker-dev.seafile.top/seafile-pro-dev:6.3-squash
docker build -t $image_name .
docker-squash --tag $suqash_image_name $image_name
docker tag $suqash_image_name $image_namedocker 
