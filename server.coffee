googlio = require './lib/googlio'
irc_bot = require './lib/irc_bot'

username = process.env.NICK || 'mobile-bot'
channel = process.env.CHANNEL || '#mobile-bot'
debug = process.env.DEBUG_NICK
http_port = process.env.PORT || 3000
host = process.env.HTTP_HOST || 'collins.local:' + http_port

    
bot = irc_bot process.env.IRC_HOST
            , username
            , port: process.env.IRC_PORT
            , channels: [channel]
            , realName: "Mobile Team Bot"
            , userName: username
            , password: process.env.IRC_PASSWORD
            , secure: (process.env.IRC_USE_SECURE == 'YES')
            , debug: true
   
watcher = googlio ()->
  bot.broadcast "#{googlio.URL} has changed, time to register!"

bot.broadcast = (message)->
  for name, channel of @.client.chans
    @say name, message

bot.command
  name: 'status'
  help: 'Reports status of url monitoring'
  action: (from, channel, args, text)->
    status = if watcher.running then "watching" else "not watching"
    @say channel, "#{status} #{googlio.URL}"
    if watcher.last_request_at
      duration = (new Date).getTime() - watcher.last_request_at.getTime()
      time = (Math.round(duration/10) / 100) + ' seconds'
      wait = (watcher.getWaitTime() / 1000) + ' seconds'
      @say channel, "Last response was #{time} ago and checking every #{wait}"
      
bot.command
  name: 'start'
  matcher: /^(start|watch)/i,
  help: 'Starts watching the url'
  action: (from, channel)->
    if watcher.running
      @say channel, "Already watching"
    else
      @say channel, "Started watching #{googlio.URL}"
      watcher.start()
      
bot.command      
  name: 'stop'
  help: 'Stop watching the url'
  action: (from, channel)->
    if watcher.running
      @say channel, "Shuting 'er down"
      watcher.stop()
    else
      @say channel, "I'm not running yet"
      
bot.command
  name: 'broadcast'
  matcher: /^broadcast(.*)$/i,
  help: false,
  action: (from, channel, args, text)->
    message = args[1].trim()
    if message == ""
      @say channel, "You didn't tell me what to say"  
    else
      @broadcast message

bot.command
  name: 'coffee',
  matcher: /(make|brew).*(coffee|java)/,
  help: false,
  action: (from, channel, args, text)->
    @say channel, "I'm a bot, #{from}, I don't know how to make #{args[2]}"