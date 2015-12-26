#
# Routes
#
version = require 'version-healthcheck'

app = module.parent.exports.app

main = require './controllers/main'

# Submit and retrieve SRI tests
app.get '/api/v1/tests', main.notImplemented
app.head '/api/v1/tests', main.create
app.post '/api/v1/tests', main.create
app.head '/api/v1/tests/:id', main.getOne
app.get '/api/v1/tests/:id', main.getOne
app.put '/api/v1/tests/:id', main.notImplemented
app.del '/api/v1/tests/:id', main.notImplemented

# Retrieve stats
app.head '/api/v1/stats', main.getStats
app.get '/api/v1/stats', main.getStats

# Health Checks
app.head '/version', version
app.get '/version', version
