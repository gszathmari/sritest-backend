chai = require 'chai'

logger = require '../../src/helpers/logger'

expect = chai.expect

describe 'Helper: logger', ->
  it 'should create a winston object', ->
    expect(logger).to.have.property('transports')
