chai = require 'chai'

config = require '../../src/helpers/config'

expect = chai.expect

describe 'Helper: config', ->
  it 'should read the configuration file in', ->
    expect(config).have.property('general')
    expect(config.general).have.property('CORS')
    expect(config.general.CORS).have.property('allowed_origins')
    expect(config.general.CORS.allowed_origins).to.be.an('array')
