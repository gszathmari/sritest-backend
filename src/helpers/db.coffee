mysql = require 'mysql'
logger = require './logger'

host = process.env.DB_HOST or '127.0.0.1'
port = process.env.DB_PORT or 3306
user = process.env.DB_USER or 'root'
password = process.env.DB_PASSWORD or 'root'
database = process.env.DB_NAME or 'sritest'

pool = mysql.createPool
  host: host
  port: port
  user: user
  password: password
  database: database

pool.on 'connection', (connection) ->
  logger.debug "Connected to MySQL database on #{host}"

pool.on 'error', (err) ->
  logger.error "Database error: #{err.message}"

module.exports = pool
