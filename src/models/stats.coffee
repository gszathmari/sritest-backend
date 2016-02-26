_ = require 'lodash'

db = require '../helpers/db'
logger = require '../helpers/logger'
rebuildId = require '../helpers/rebuildid'

class Stats
  constructor: ->
    @results = new Array

  retrieve: (fn) ->
    statsObj = @
    db.getConnection (err, connection) =>
      # Return with error if database fails
      if err
        return fn err, statsObj
      else
        q = 'SELECT LOWER(HEX(`reportid`)) AS `reportid`, `url`, `tags` FROM reports WHERE `hidden` = 0 ORDER BY `id` DESC LIMIT 50'
        connection.query q, (err, results) =>
          # Release database connection into pool
          connection.release()
          # Return error if database query fails
          if err
            return fn err, statsObj
          # Process results
          else
            # Write results into this object 'results' variable
            @results = _.map results, (item) ->
              # Parse script/css tags into object
              tags = JSON.parse item.tags
              # Build a single stats item
              statItem =
                # Re-generate UUID format
                id: rebuildId item.reportid
                url: item.url
                # Calculate stats from parsed tags
                stats:
                  unsafe: tags.scripts.unsafe.length +
                    tags.stylesheets.unsafe.length
                  safe: tags.scripts.safe.length +
                    tags.stylesheets.safe.length +
                    tags.scripts.sameorigin.length +
                    tags.stylesheets.sameorigin.length
              return statItem
            # Return object with results in it
            return fn null, statsObj

  get: ->
    return @results

module.exports = Stats
