chai = require 'chai'
sinon = require 'sinon'

addHeaders = require '../../src/middlewares/addheaders'

expect = chai.expect

describe 'Middleware: addheaders', ->
  req = sinon.spy()
  res =
    header: sinon.spy()
  next = sinon.spy()
  header =
    key: 'Powered-by'
    value: 'node-restify-coffee-boilerplate'

  it 'should add header to response', ->
    r = addHeaders req, res, next
    expect(req.called).to.be.false
    expect(res.header.calledWith header.key, header.value).to.be.true
    expect(next.calledOnce).to.be.true

  after ->
    req.reset()
    res.header.reset()
    next.reset()
