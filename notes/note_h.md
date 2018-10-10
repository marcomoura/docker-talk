## Antes de rodar o lint vou usar duas opções do CONTAINER EXEC o tty e interactive

-it significa --interactive --tty.

É usado para fixar a linha de comando com o contêiner, assim,
após esse docker container run,
todos os comandos são executados pelo bash de dentro do contêiner.

Para sair use exit ou pressione Control-d

 docker container run elixir iex
 iex => 1 + 2
 2 * 2
 6 / 3


 docker container run --tty --interactive elixir iex
 iex => 1 + 2
 3
 iex => 2 * 2
 4
 iex => 6 / 3
 2.0

### rodar credo

Rodar o credo
rodar o test e verificar deixa para configurar o banco de dados

Usar o commando RUN
###

# próximo slide!! -- banco de dados com o RUN e ALPINE
