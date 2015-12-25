winston = require 'winston'
papertrail = require 'winston-papertrail'

options =
  transports: [
    new winston.transports.Console
  ]

if process.env.PAPERTRAILAPP_HOST and process.env.PAPERTRAILAPP_PORT
  papertrail.Papertrail
  papertrailappOpts =
    host: process.env.PAPERTRAILAPP_HOST
    port: process.env.PAPERTRAILAPP_PORT
  papertrailapp = new winston.transports.Papertrail papertrailappOpts
  options.transports.push papertrailapp

logger = new winston.Logger options

module.exports = logger
