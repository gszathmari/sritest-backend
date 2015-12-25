#
# Add arbitrary HTTP headers to responses
#

addHeaders = (req, res, next) ->
  res.header 'Powered-by', 'node-restify-coffee-boilerplate'
  return next()

module.exports = addHeaders
