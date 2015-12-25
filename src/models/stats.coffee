redis = require '../helpers/db'

class Stats
  constructor: ->
    @q = 'hashkeys BY report:*->submitted GET report:*->url GET
      report:*->tags DESC LIMIT 0 50'
    @results = new Array
    @key = 'statsdata'
    @ttl = 60

  retrieve: (fn) ->
    statsObj = @
    redis.get @key, (err, results) =>
      # Get stats from Redis
      if not err and results
        @results = JSON.parse results
        return fn null, statsObj
      # If results are not cached, retrieve from Redis and process results
      else
        redis.sort @q.split(" "), (err, results) =>
          # Return Stats object when ready
          if err
            return fn err, statsObj
          else
            # Process results
            while results.length > 0
              # Splice array to get individual item data
              item = results.splice 0, 2
              # Convert script and stylesheet tags into object
              tags = JSON.parse item[1]
              # Construct statistics object
              itemStats =
                url: item[0]
                stats:
                  unsafe: tags.scripts.unsafe.length +
                    tags.stylesheets.unsafe.length
                  safe: tags.scripts.safe.length +
                    tags.stylesheets.safe.length
              # Append object to array
              @results.push itemStats
              # Cache results in Redis
            redis.setex @key, @ttl, JSON.stringify @results
            # Return Stats object when ready
            return fn null, statsObj

  get: ->
    return @results

module.exports = Stats
