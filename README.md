# OmniChat

## Instalando

  1 - Instalar node.js e o MongoDB  
    [https://github.com/joyent/node/wiki/Installation](https://github.com/joyent/node/wiki/Installation)  
    [http://fastdl.mongodb.org/osx/mongodb-osx-x86_64-1.8.3.tgz](http://fastdl.mongodb.org/osx/mongodb-osx-x86_64-1.8.3.tgz)  
  
  2 - Instalar coffeeScript  
    npm install -g coffee-script  
  
  3 - Instalar as dependências do projeto  
    Testadas na versão 0.4.9 do node.js  
    npm install express socket.io mongodb@0.9.6-23 mongoskin hashlib sanitizer  
                           
## Subindo o server

  Na pasta do projeto faça:
    
  ➔ coffee server.coffee

## Subindo o mongoDB

  ➔ mongod
  
## Migrando o banco

  ➔ mongo migrations/001_create_omnichat_account.js  
     
## Usando

  Abra:  
    http://localhost:3000/example/index.html
  
  Heroku:  
    http://omnichat.herokuapp.com/example/index.html

## Compilando
  
  # Compilando todo o diretório lib  
  coffee -o build/ -c lib/  
  
  # Com watcher (dev)  
  coffee --watch -o build/ -c lib/  
  
  coffee --join public/javascripts/client.js --compile lib/client/util.coffee lib/client/client.coffee  
  coffee --watch --compile public/example/*.coffee  
