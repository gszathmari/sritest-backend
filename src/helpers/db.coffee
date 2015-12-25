Redis = require 'ioredis'

redis = new Redis process.env.REDIS_URL

module.exports = redis
