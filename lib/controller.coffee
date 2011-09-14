createServer = require("http").createServer
readFile = require("fs").readFile
url = require("url");
sys = require("sys")

class Controller
  MAP: {}
  NOT_FOUND: (request, response) ->
    response.writeHead(404, {
      "Content-Type": "text/plain",
      "Content-Length": "Not Found\n".length
    })
    response.end("Not Found\n")

  constructor: ->
    @server = this._createServer()

  get: (path, handler) ->
    sys.puts("registering: #{path}")
    Controller::MAP[path] = handler

  listen: (port, host) ->
    @server.listen(port, host)
    sys.puts("Server at http://#{host || '127.0.0.1'}:#{port}/")

  close: ->
    @server.close()

  _createServer: ->
    createServer (request, response) ->
      if request.method == "GET" or request.method == "HEAD"
        pathname = url.parse(request.url).pathname
        sys.puts("GET - pathname: #{pathname}")

        handler = Controller::MAP[pathname] || Controller::NOT_FOUND
        response.simpleText = (code, body) ->
          response.writeHead(code, {
            "Content-Type": "text/plain",
            "Content-Length": body.length
          })
          response.end(body)

        response.simpleJSON = (code, obj) ->
          body = new Buffer(JSON.stringify(obj))
          response.writeHead(code, {
            "Content-Type": "text/json",
            "Content-Length": body.length
          })
          response.end(body)

        handler(request, response)

module.exports = Controller