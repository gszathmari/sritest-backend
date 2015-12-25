#
# Read configuration file
#

yaml = require 'js-yaml'
fs = require 'fs'

logger = require './logger'

# Open main configuration file
try
  path = '../../config/global.yaml'
  config = yaml.safeLoad fs.readFileSync __dirname + '/' + path, 'utf8'
catch err
  logger.error "ERROR: Error reading the global configuration file!"
  throw new Error "Error reading the configuration file"

module.exports = config
