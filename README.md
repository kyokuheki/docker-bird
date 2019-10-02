# docker-bird

## usage
run bird daemon

```
mkdir -p /srv/bird/etc /srv/bird/run
vim /srv/bird/etc/bird.conf
docker run -d --rm --name bird -p179:179/tcp -v/srv/bird/etc:/etc/bird -v/srv/bird/run:/var/run/bird kyokuheki/bird
```

run bird client

```shell
docker run -it --rm --name birdc -v/srv/bird/run:/var/run/bird --entrypoint=/usr/sbin/birdc kyokuheki/bird
```

## build

```shell
git clone https://github.com/kyokuheki/docker-bird.git
docker build docker-bird -t bird
```
