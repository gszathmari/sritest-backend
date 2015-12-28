Memcached = require 'memcached'

server = process.env.MEMCACHED_PORT_11211_TCP_ADDR or "127.0.0.1"
memcached = new Memcached server

module.exports = memcached
