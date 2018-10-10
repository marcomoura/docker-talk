# container run

cria uma image

Vou usar uma image alpine, é uma imagem menor de +-80mb

`docker container run --detach --name database postgres:11-alpine`

Altera a configuração de banco do test
`vim app/config/test.exs`

Recria o container do bot
```
docker container rm -f bot
docker container create --name bot -v $(pwd)/app:/home/app --link database elixir
docker container exec -it bot bash
cd /home/app
mix test

mix run --no-halt

exit
vim app/config/dev.exs

docker container exec -it bot bash
cd /home/app
mix run --no-halt
curl localhost:4001/github
```

Falta configurar a porta

# próximo slide Publish port!!
