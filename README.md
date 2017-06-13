# About this Repo

This is the Git repo of the official Docker image for [amixsi/bhl-web](https://hub.docker.com/r/amixsi/bhl-web/).
See the Hub page for the full readme on how to use the Docker image and for information regarding contributing and issues.

Common build usage:

```bash
docker build \
  --build-arg "http_proxy=$http_proxy" \
  --build-arg "https_proxy=$https_proxy" \
  --build-arg "no_proxy=$no_proxy" \
  -t bhl-web \
  -t bhl-web:co5v3 \
  .
```

Publish image:

```bash
docker tag bhl-web:latest amixsi/bhl-web:latest
docker tag bhl-web:co5v3 amixsi/bhl-web:co5v3
```
