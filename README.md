# OmniChat

## Instalando

  1 - Instalar node.js  
    [https://github.com/joyent/node/wiki/Installation](https://github.com/joyent/node/wiki/Installation)  
  
  2 - Instalar coffeeScript  
    npm install -g coffee-script  
  
  3 -
    npm install express socket.io  

## Subindo o server

  Na pasta do projeto faça:
    
  ➔ coffee server.coffee  
    
## Usando

  Abra:  
    http://localhost:3000/example/index.html
  
  Heroku:
    http://omnichat.herokuapp.com/example/index.html

## Compilando
    
  coffee --watch --join public/javascripts/client.js --compile lib/client/util.coffee lib/client/client.coffee  
  coffee --watch --compile server.coffee public/example/example.coffee  
  