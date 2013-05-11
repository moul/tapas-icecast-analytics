exports.tapas =
  port: 9512
  debug: false
  locals:
    site_name:    'Icecast Analytics'
    author:       'Manfred Touron'
    description:  'Icecast Analytics'
    use:
      jquery: true
      bootstrap:
        fluid: true
        responsive: false

exports.statsd =
  host: '127.0.0.1'
  port: 8125
  prefix: 'icecast-analytics'

exports.icecast_servers =
  servers: require(process.env[if process.platform == 'win32' then 'USERPROFILE' else 'HOME'] + '/.icecast-servers.json')
  # or
  #servers: [
  #  'http://admin:pass@icecast-server-1.com:8000/'
  #  'http://admin:pass@icecast-server-2.com:8000/'
  # ]

exports.timer = 100

try
  require('./config.local') exports
catch e
  console.log ''
