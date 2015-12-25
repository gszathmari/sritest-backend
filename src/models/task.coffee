request = require 'request'
cheerio = require 'cheerio'
uuid = require 'uuid'

Report = require '../models/report'
config = require '../helpers/config'
logger = require '../helpers/logger'
normalizeURL = require '../helpers/normalizeurl'

class Task
  constructor: ->
    @submitted = Math.floor(Date.now() / 1000)
    @id = uuid.v4()

  # Gets page from user submitted URL
  pull: (url, hidden, fn) ->
    targetURL = normalizeURL url
    # Construct options for the request library
    options =
      url: targetURL
      headers:
        'User-Agent': config.http_client.user_agent
      timeout: config.http_client.timeout
      strictSSL: false
      gzip: true
      followRedirect: false
    # Submit HTTP request to retrieve page
    request options, (err, response, body) =>
      if err
        logger.warn "Error while retrieving remote #{targetURL}"
      else
        # Construct report
        report =
          # Report ID
          id: @id
          # Hidden flag
          hidden: hidden
          # Task Submitted Unix timestamp
          submitted: @submitted
          # Target URL
          url: targetURL
          # Store error message
          error: err?.message
          # Status code of remote website
          statusCode: response.statusCode
          # Script and stylesheet tags
          tags: @generateTags body
        report = new Report report
        report.save (err) ->
          if err
            # Return error if save was unsuccessful
            logger.error "Redis error while saving Report: #{err.message}"
    # Return report ID immediately
    return fn null, @id

  # Calculates SRI stats from the webpage source
  generateTags: (body) ->
    # Load HTML into cheerio
    $ = cheerio.load body.toString()
    # Get <script> tags
    scripts = $('script[src]')
    # Get <link rel="stylesheet"> tags
    stylesheets = $('link[rel=stylesheet]')
    # Define callback for .map() function below
    fn = (i, el) ->
      return $.html(el)
    # Construct response that the user will receive
    tags =
      scripts:
        #all: scripts.map(fn).toArray()
        safe: scripts.filter('[integrity]').map(fn).toArray()
        unsafe: scripts.filter(':not([integrity])').map(fn).toArray()
      stylesheets:
        #all: stylesheets.map(fn).toArray()
        safe: stylesheets.filter('[integrity]').map(fn).toArray()
        unsafe: stylesheets.filter(':not([integrity])').map(fn).toArray()
    return JSON.stringify tags

module.exports = Task
