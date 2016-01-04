redis = require '../helpers/db'
logger = require '../helpers/logger'

class Stats
  constructor: ->
    @q = 'hashkeys BY report:*->submitted GET report:*->url GET
      report:*->tags DESC LIMIT 0 50'
    @results = new Array

  retrieve: (fn) ->
    statsObj = @
    redis.sort @q.split(" "), (err, results) =>
      # Return Stats object when ready
      if err
        return fn err, statsObj
      else
        # Process results
        while results.length > 0
          try
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
                  tags.stylesheets.safe.length +
                  tags.scripts.sameorigin.length +
                  tags.stylesheets.sameorigin.length
            # Append object to array
            @results.push itemStats
          catch err
            logger.debug "Error while assembling statistics: #{err.message}"
            logger.debug err.stack
        # Return Stats object when ready
        return fn null, statsObj

  get: ->
    return @results

module.exports = Stats
