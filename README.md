# HTML Subresource Integrity Tester Backend

This is the backend of [sritest.io](https://sritest.io)

[![Travis branch](https://img.shields.io/travis/gszathmari/sritest-backend/master.svg)](https://travis-ci.org/gszathmari/sritest-backend)
[![](https://badge.imagelayers.io/gszathmari/sritest-backend:latest.svg)](https://imagelayers.io/?images=gszathmari/sritest-backend:latest 'Get your own badge on imagelayers.io')
[![devDependency Status](https://david-dm.org/gszathmari/sritest-backend/dev-status.svg)](https://david-dm.org/gszathmari/sritest-backend#info=devDependencies)
[![Code Climate](https://codeclimate.com/github/gszathmari/sritest-backend/badges/gpa.svg)](https://codeclimate.com/github/gszathmari/sritest-backend)

## Environmental Variables

* `REDIS_URL`: Database where SRI reports are stored. Declare in `redis://host:port` format
* `PAPERTRAILAPP_HOST`: _(optional)_ Hostname of [Papertrail](https://papertrailapp.com) service for remote logging
* `PAPERTRAILAPP_PORT`: _(optional)_ Port of [Papertrail](https://papertrailapp.com) service for remote logging
* `NEW_RELIC_LICENSE_KEY`: _(optional)_ [Newrelic](http://www.newrelic.com) API key for performance monitoring

## Running the application

Install the dependencies first with the following commands:

```
$ npm install
```

```
$ npm install -g
```

### Developer mode

Simply run the service with gulp:

```
$ gulp serve
```

### Production

Compile the CoffeeScript into JavaScript first:

```
$ gulp build
```

Then start the backend with the following:

```
$ npm start
```

## Testing

TBD

## Contributors

- [Gabor Szathmari](http://gaborszathmari.me) - [@gszathmari](https://twitter.com/gszathmari)

## License

See the [LICENSE](LICENSE) file for license rights and limitations (MIT)
