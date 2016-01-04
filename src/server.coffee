#
# Main API Server
#
# Newrelic should be on the top
newrelic = require './helpers/newrelic'
cors = require './helpers/cors'

restify = require 'restify'
chalk = require 'chalk'

config = require './helpers/config'
exceptionHandler = require './helpers/exceptionhandler'
logger = require './helpers/logger'
addHeaders = require './middlewares/addheaders'

app = module.exports = restify.createServer()
corsOptions =
  origins: config.general.CORS.allowed_origins
  #credentials: true

#
# Applying Restify built-in plugins and other helpers
#

# Add CORS header support here
app.pre cors.preflight
app.use cors.actual
# Restify workaround for cURL
app.pre restify.pre.userAgentConnection()
# Restify workaround for handling trailing slashes
app.pre restify.pre.sanitizePath()
# Restify helpers to parse body and query parameters
app.use restify.bodyParser()
app.use restify.queryParser()

#
# Applying custom helpers
#

# Use custom helper to add custom headers
app.use addHeaders
# Prevents leaking internal errors through the API
app.on 'uncaughtException', exceptionHandler

#
# Launching server
#

server = app.listen process.env.PORT or 8080, ->
  address = server.address().address
  port = server.address().port
  logger.info \
    chalk.green "Server listening on http://#{address}:#{port} " +
    chalk.grey "(PID: #{process.pid})"

module.exports.app = app
routes = require './routes'
