corsMiddleware = require 'restify-cors-middleware'

config = require './config'

options =
  origins: config.general.CORS.allowed_origins
  preflightMaxAge: 15

cors = corsMiddleware options

module.exports = cors
