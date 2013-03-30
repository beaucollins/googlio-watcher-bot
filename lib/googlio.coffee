https = require 'https'
http = require 'http'
crypto = require 'crypto'
events = require 'events'

URL = "https://developers.google.com/events/io/"
# URL = "http://collins.local/bottest.html"
DEFAULT_WAIT_TIME = 5000
Watcher = ()->
  events.EventEmitter.apply(this)
  @hash = null
  @running = false
  @requests = 0
  @wait_time = DEFAULT_WAIT_TIME
  
Watcher.prototype = Object.create events.EventEmitter.prototype

Watcher.prototype.getWaitTime = ()->
  @wait_time

Watcher.prototype.setWaitTime = (time)->
  @wait_time = time

Watcher.prototype.start = ()->
  return @ if @running
  @running = true
  @.fetch()
  @

Watcher.prototype.stop = ()->
  return @ unless @running
  @running = false
  clearTimeout(@timer)
  @

get = (url)->
  transport = if url.match /^https/ then https else http
  transport.get.apply(transport, arguments)

Watcher.prototype.fetch = ()->
  watcher = @
  get URL, (res)->
    hasher = crypto.createHash 'md5'
    res.on 'data', (data)->
      hasher.update data
    res.on 'end', ()->
      watcher.last_request_at = new Date()
      newHash = hasher.digest('hex')
      if watcher.hash == null
        watcher.emit 'start'
      else if watcher.hash != newHash
        watcher.emit 'change'
      watcher.hash = newHash
      watcher.timer = setTimeout ()->
        watcher.fetch()
      , watcher.getWaitTime() if watcher.running
      
module.exports = (callback)->
  (new Watcher).on('change', callback).start()
  
module.exports.URL = URL
module.exports.Watcher = Watcher  
      
