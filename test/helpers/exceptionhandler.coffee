chai = require 'chai'
sinon = require 'sinon'

exceptionHandler = require '../../src/helpers/exceptionhandler'

expect = chai.expect

describe 'Helper: exceptionhandler', ->
  # Stub request and response objects and other call parameters
  req = sinon.spy()
  res =
    json: sinon.spy()
  err = new Error "Unit testing, please ignore"
  # Message from exceptionHandler
  jsonResponse =
    message: "InternalServerError"
    description: "Ouch! Internal server error, please try again"

  it 'should return generic error message', ->
    try
      r = exceptionHandler req, res, null, err
    # Exception handler should produce an exception, therefore this is expected
    catch err
      expect(err.message).to.contain('Uncaught Exception')
      expect(req.called).be.false
      expect(res.json.calledOnce).be.true
      expect(res.json.calledWith 500, jsonResponse).be.true

  after ->
    req.reset()
    res.json.reset()
