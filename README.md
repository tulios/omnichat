# OmniChat

## Instalando

  1 - Instalar node.js
    https://github.com/joyent/node/wiki/Installation
  
  2 - Instalar coffeeScript 
    npm install -g coffee-script

## Subindo o server

  Na pasta do projeto faça:
    
  ➔ coffee server.coffee
    
## Usando

  Só fiz o server, logo não temos nada de client por enquanto, o chat rola no terminal =P
  Abra outra aba.

  ➔  curl 127.0.0.1:3000/join?nick=tulios
  ➔  curl 127.0.0.1:3000/who
  ➔  curl 127.0.0.1:3000/send?id=58175407628&text=oi!
  
  58175407628 = sessionId do usuário, pra testar tem que pegar esse número na aba de server