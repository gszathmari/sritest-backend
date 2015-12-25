_ = require 'lodash'

Report = require '../models/report'
ReportSchema = require '../models/reportschema'
redis = require '../helpers/db'
config = require '../helpers/config'

# Based on http://timjrobinson.com/how-to-structure-your-nodejs-models-2/
class Report
  constructor: (data) ->
    @data = @sanitize data

  sanitize: (data) ->
    data = data or {}
    schema = ReportSchema
    return _.pick(_.defaults(data, schema), _.keys(schema))

  save: (fn) ->
    @data = @sanitize @data
    self = @
    statsKey = config.reports.hashkeys
    ttl = config.reports.ttl
    key = config.reports.prefix + @data.id
    # Store result in Redis
    pipeline = redis.pipeline()
    # Store result
    pipeline.hmset key, @data
    # Set TTL value
    pipeline.expire key, ttl
    # Add report ID to statistics if not hidden
    unless @data.hidden
      pipeline.lpush statsKey, @data.id
    # Execute Redis commands
    pipeline.exec (err) ->
      if err
        return fn err, self
      else
        return fn null, self

  findById: (id, fn) ->
    key = config.reports.prefix + id
    # Pull data from database
    redis.hgetall key, (err, report) ->
      # Return with error if Redis fails
      if err
        return fn err, null
      # Generate error when item is not found
      else if Object.keys(report).length is 0
        return fn null, null
      else
        # Dump response into page object and return object back
        report =
          id: report.id
          hidden: report.hidden
          submitted: report.submitted
          url: report.url
          error: report.error
          statusCode: report.statusCode
          tags: report.tags
        return fn null, new Report report

  get: (name) ->
    return @data[name]

  set: (name, value) ->
    @data[name] = value

module.exports = Report
