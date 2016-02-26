_ = require 'lodash'
boolean = require 'boolean'

Report = require '../models/report'
ReportSchema = require '../models/reportschema'
db = require '../helpers/db'
config = require '../helpers/config'
rebuildId = require '../helpers/rebuildid'

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
    db.getConnection (err, connection) =>
      if err
        return fn err, self
      else
        q = 'INSERT INTO reports SET `reportid` = UNHEX(REPLACE(?,"-","")), `statuscode` = ?, `error` = ?, `tags` = ?, `url` = ?, `hidden` = ?'
        inserts = [
          @data.id,
          @data.statusCode,
          @data.error,
          @data.tags,
          @data.url,
          @data.hidden
        ]
        connection.query q, inserts, (err) ->
          connection.release()
          # Return with error if database throws an error
          if err
            return fn err, self
          # Return without error if INSERT was successful
          else
            return fn null, self

  findById: (reportid, fn) ->
    db.getConnection (err, connection) ->
      # Return with error if database fails
      if err
        return fn err, null
      else
        q = 'SELECT LOWER(HEX(`reportid`)) AS `reportid`, UNIX_TIMESTAMP(`submitted`) AS `submitted`, `url`, `statuscode`, `tags`, `error`, `hidden` FROM reports WHERE reportid = UNHEX(REPLACE(?,"-",""))'
        connection.query q, [reportid], (err, results) ->
          # Release database connection into pool
          connection.release()
          if results.length > 0
            # Dump response into page object and return object back
            report =
              id: rebuildId results[0].reportid
              hidden: boolean results[0].hidden
              submitted: results[0].submitted
              url: results[0].url
              error: results[0].error or ""
              statusCode: results[0].statuscode
              tags: results[0].tags
            return fn null, new Report report
          else
            # Return empty object if report is not found
            return fn null, null

  get: (name) ->
    return @data[name]

  set: (name, value) ->
    @data[name] = value

module.exports = Report
