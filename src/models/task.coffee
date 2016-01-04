request = require 'request'
cheerio = require 'cheerio'
uuid = require 'uuid'
sameOrigin = require 'same-origin'
url = require 'url'
_ = require 'lodash'

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
          tags: @generateTags body, targetURL
        report = new Report report
        report.save (err) ->
          if err
            # Return error if save was unsuccessful
            logger.error "Redis error while saving Report: #{err.message}"
    # Return report ID immediately
    return fn null, @id

  # Returns true if origin matches between target URL and URL in the tag
  compareOrigins: (tagURL, targetURL) ->
      # Match URLs like <script src="/js/track.js">
      if tagURL.match /^\/\w+/
        return true
      # Match URLs like <script src="js/track.js"> but not <script src="http://...
      else if (tagURL.match /^\w+/) and (not tagURL.match /^http.+/)
        return true
      # Test with same origin library
      else if sameOrigin targetURL, tagURL
        return true
      # Match URLs like <script src="//example.com/js/track.js">
      else if tagURL.match /^\/\/\w.*/
        # Get domain from target URL
        targetURLObj = url.parse targetURL
        # Assemble tag URL: // => http://
        tagURL = targetURLObj.protocol + tagURL
        # Compare target URL and URL in tag
        return sameOrigin targetURL, tagURL
      # Return false if all tests fail
      else
        return false

  # Calculates SRI stats from the webpage source
  generateTags: (body, targetURL) ->
    # Load HTML into cheerio
    $ = cheerio.load body.toString()
    # Get <script> tags
    scripts = $('script[src]')
    # Get <link rel="stylesheet"> tags
    stylesheets = $('link[rel=stylesheet]')
    # Define callback for .map() function below
    fn = (i, el) ->
      return $.html(el)

    # Transform tags into arrays based on filters
    tags =
      safe:
        scripts: _.uniq scripts.filter('[integrity]').map(fn).toArray()
        stylesheets: _.uniq stylesheets.filter('[integrity]').map(fn).toArray()
      unsafe:
        scripts: _.uniq scripts.filter(':not([integrity])').map(fn).toArray()
        stylesheets: _.uniq stylesheets.filter(':not([integrity])').map(fn).toArray()
      sameorigin: {}

    # Separate script tags on the same origin
    tags.sameorigin.scripts = _.filter tags.unsafe.scripts, (script) =>
      # Pattern for matching the contents of <script src="">
      regex = /.+src\=\"(.+)\".+/
      # Extract URL from script tag, Array[1] will contain the URL
      scriptSrcMatch = script.match regex
      # Return true/false for _.filter function
      return @compareOrigins scriptSrcMatch[1], targetURL

    # Separate stylesheet tags on the same origin
    tags.sameorigin.stylesheets = _.filter tags.unsafe.stylesheets, (link) =>
      # Pattern for matching the contents of <link href="">
      regex = /.+href\=\"(.+)\".+/
      # Extract URL from link tag, Array[1] will contain the URL
      linkHrefMatch = link.match regex
      # Return true/false for _.filter function
      return @compareOrigins linkHrefMatch[1], targetURL

    # Construct response that the user will receive
    results =
      scripts:
        #all: scripts.map(fn).toArray()
        safe: tags.safe.scripts
        unsafe: _.difference tags.unsafe.scripts, tags.sameorigin.scripts
        sameorigin: tags.sameorigin.scripts
      stylesheets:
        #all: stylesheets.map(fn).toArray()
        safe: tags.safe.stylesheets
        unsafe: _.difference tags.unsafe.stylesheets, tags.sameorigin.stylesheets
        sameorigin: tags.sameorigin.stylesheets
    return JSON.stringify results

module.exports = Task
