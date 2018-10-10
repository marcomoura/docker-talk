# publish

`curl localhost:4001/github`

se o banco de dados estivesse instalado no host usaria o domain
localhost, o q não funciona com o container pq localhost aponta para o host
então é necessário criar um link entre os containers e o docker
cria um rede virtual entre os containers, defininado um hostname para
ser utilizado entre os containers, o hostname será o nome dos containers

A app bot tem uma stack simples, mas com um cenário com redis, elasticsearch
loadbalancer, ainda é possivel gerenciar td através da linha de comando,
mas o docker-compose é a ferramenta apropriada e melhor para esse tipo de
tarefa, ao menos em desenvolvimento

# próximo slide!! Dockerfile
