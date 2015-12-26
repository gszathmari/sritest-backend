newrelic = ->
  appName = "sritest"
  key = process.env.NEW_RELIC_LICENSE_KEY

  require 'newrelic' if key

module.exports = newrelic()
