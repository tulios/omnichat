createServer = require("http").createServer
readFile = require("fs").readFile
url = require("url");
sys = require("sys")

class HttpServer
  NOT_FOUND: (request, response) ->
    response.writeHead(404, {
      "Content-Type": "text/plain",
      "Content-Length": "Not Found\n".length
    })
    response.end("Not Found\n")

  constructor: ->
    @routes = {}

  mergeRoutes: (controller) ->
    for own route of controller.routes
      @routes[route] = controller.routes[route]

  listen: (port, host) ->
    @server = this._createServer()
    @server.listen(port, host)
    sys.puts("\nServer at http://#{host || '127.0.0.1'}:#{port}/\n")

  close: ->
    @server.close()

  _createServer: ->
    routes = @routes
    createServer (request, response) ->
      if request.method == "GET" or request.method == "HEAD"
        pathname = url.parse(request.url).pathname
        sys.puts("GET - pathname: #{pathname}")

        handler = routes[pathname] || Server::NOT_FOUND
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

module.exports = HttpServer