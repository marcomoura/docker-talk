# slide A
Minha talk é sobre docker em dev

Vai levar +- 30m

Vou demonstrar:
- docker command line
- dockerfile
- docker-compose.yml

# slide B - Objetivo
- Configurar o ambiente de dev
- sem instalar nenhuma dependencia no host
- no final vamos rodar lint, test e app

- quando peguei uma maquina nova descidi configurar td via docker
- this is a working in progress

# slide C - App de exemplo
- duas dependências necessárias para rodar a app

# slide D - Overview sobre a Terminologia docker

## E O QUE É UM CONTAINER DOCKER ?

O container é onde vou executar o bot
e também
onde vou executar o banco de dados
cada um vai ficar um container, independetes

Ele é como uma maquina virtual no virtualbox

E para criamos estes containers utilizamos uma imagem docker

É na imagem que definimos as caractericas do container, como
OS (debian, ubuntu), porta...

Analogia OOP
Um containers docker é como uma instancia de uma classe em OOP
Uma image docker um classe em OOP, onde definimos os atributos e funções
e um container é uma instancia, roda em memória e a executa o serviço ou funcao

Então voltando ao workflow,
para rodar a aplicação precisamos de um container com elixir
para criamos o container precisamos de uma imagem com elixir

vou sair do slide e vou para o bash executar os comandos

# MUDAR SLIDE!! -- Commandos para Gerenciar imagens
