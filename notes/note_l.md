# Dockerfile

O Dockerfile define como uma image é construida

from BASE_IMAGE

outros comandos
COPY

```
ls
docker image build --tag bot_image .
docker image ls <= demonstrar a imagem criada
```

```
docker container run --name bot -v $(pwd)/app:/home/app --link bot_db -p 4001:4001 -it bot_image bash
```
