newrelic = ->
  appName = "sritest"
  key = process.env.NEWRELIC_LICENSE_KEY

  require 'newrelic' if key

module.exports = newrelic()
