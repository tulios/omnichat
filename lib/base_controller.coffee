sys = require("sys")

class BaseController
  constructor: (sessionManager) ->
    @routes = {}
    @sessionManager = sessionManager

  sessionManager: ->
    @sessionManager

  get: (path, handler) ->
    console.log("registering path: #{path}")
    @routes[path] = handler

module.exports = BaseController