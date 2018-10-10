## docker compose

Ao invés de executar os comandos com várias opções
usamos o compose para especificar as opções do container
e salvar em um arquivo de configuração

```
docker container rm -f bot bot_db

docker-compose up --detach

docker-compose exec app bash

mix ecto.create
mix ecto.migrate

mix run credo
mix run test
mix run --no-halt
```

qualquer um do time pode rodar o ambiente com com docker-compose up

## Final notes
Agora que temos o ambiente configurado podemos compartilhar, e
ajustar apenas se necessário

um dev novo ou o uso de uma máquina nova basta installar o
docker, fazer o clone do repo e
o ambiente está pronto
