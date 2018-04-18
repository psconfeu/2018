break
# set correct location before start!
#cd "~\Documents\github\psconfeu2018-shared\demo\02 - docker-build"

# Dockerbuild uses it's own DSL
# see https://docs.docker.com/engine/reference/commandline/build/

# different ways of calling docker build
docker build --platform linux .
# or
docker build --platform linux  --file ./Dockerfile
# or
docker build --platform linux  -f ./Dockerfile
# or
Get-Content -Path ./DockerFile | docker build --platform linux  -

# tag image
docker build --platform linux -t custom/mgmt:1.0 .