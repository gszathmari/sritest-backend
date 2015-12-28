restify = require 'restify'
validator = require 'validator'
boolean = require 'boolean'

Task = require '../models/task'
Report = require '../models/report'
Stats = require '../models/stats'
config = require '../helpers/config'
logger = require '../helpers/logger'
memcached = require '../helpers/memcached'

exports.notImplemented = (req, res, next) ->
  message = "Oh noes, this feature is missing"
  response = new restify.NotImplementedError(message)
  return next response

# Retrieve statistics (last submitted task, last results)
exports.getStats = (req, res, next) ->
  key = 'stats'
  ttl = 2 * 60
  # Get response from cache
  memcached.get key, (err, response) ->
    if not err and response
      res.cache()
      res.json response
      return next()
    # Retrieve response from database if not found in cache
    else
      stats = new Stats
      stats.retrieve (err, stats) ->
        if err
          message = "Error retrieving statistics, please try again later"
          response = new restify.InternalServerError(message)
          return next response
        else
          response = stats.get()
          # Store response in Memcached
          memcached.set key, response, ttl, (err) ->
            res.cache()
            res.json response
            return next()

# Creates new task submits for processing
exports.create = (req, res, next) ->
  # Validate user submitted URL
  unless validator.isURL req.params.url, config.validator.protocols
    message = "Submitted URL is not valid, please try again"
    response = new restify.BadRequestError(message)
    return next response
  else
    url = req.params.url.toString()
    hidden = boolean(req.params.hide)
    # Create task object
    task = new Task
    # Start processing and return with future report ID
    task.pull url, hidden, (err, id) ->
      if err
        # We had an unknown error while submitting the task
        logger.warn "Error while submitting task: #{err.message}"
        message = "Remote server is unavailable or the URL is not valid."
        response = new restify.BadRequestError(message)
        return next response
      else
        # Send back the ID of the report, task has been submitted for processing
        response =
          message: "Request has been submitted successfully"
          success: true
          id: id
        res.json response
        return next()

# Retrieves SRI report by ID
exports.getOne = (req, res, next) ->
  # Cache response in Memcached for this amount of seconds
  ttl = 60 * 60
  # Validate user submitted ID
  unless validator.isUUID req.params.id, 4
    message = "Report ID parameter is not valid, please try again"
    response = new restify.BadRequestError(message)
    return next response
  else
    # Report ID
    id = req.params.id.toString()
    memcached.get id, (err, response) ->
      if not err and response
        res.cache()
        res.json response
        return next()
      else
        # Create task object
        report = new Report
        # Pull report from database using the ID
        report.findById id, (err, report) ->
          # If we have an error while returning report, respond with HTTP 500
          if err
            logger.warn "Error while retrieving report: #{err.message}"
            message = "Error retrieving report, please try again later"
            response = new restify.InternalServerError(message)
            return next response
          # If report is not found, return HTTP 404
          else if report is null
            message = "Report is not available yet, please try again later"
            response = new restify.NotFoundError(message)
            return next response
          # If report is ready, return the report back to the user
          else
            response =
              message: "Report has successfully been retrieved"
              success: true
              results: report.data
            memcached.set id, response, ttl, (err) ->
              res.cache()
              res.json response
              return next()
