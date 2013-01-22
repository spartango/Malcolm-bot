require 'rubygems'
require 'blather/client'
require './bot/bitbot'
require './bot/gistbot'
require './bot/malcolm'

require 'logger'

# Core Logger init
log = Logger.new(STDOUT)
log.level = Logger::DEBUG

# Login info
botUsername = ''
botPassword = ''

# Optional, Gist will work without this
gistUsername = ''
gistPassword = ''

# Allowed users
# Leave this nil to allow all
allowed = nil

# Bots
gistbot = Bot::GistBot.new()
malcolm = Bot::Malcolm.new(allowed)

setup botUsername, botPassword, 'talk.google.com', 5222

# Sends all the messages in a list of messages
def send_messages(messages)
    messages.each { |m| write_to_stream m }
end

when_ready do 
    log.warn "[Core]: Ready!"
end

disconnected do 
    log.error "[Core]: Disconnected, reconnecting..."
    client.connect 
end

# Handlers

# Subscription handling
subscription :request? do |s|
    log.warn "[Core]: Got subscription "
    send_messages malcolm.onSubscribe s
end

presence do |s|
    if s.unsubscribe? 
        log.debug "[Core]: Got unsubscribe "
        send_messages malcolm.onUnsubscribe s.from.stripped.to_s
    elsif s.unavailable?
        log.debug "[Core]: Got unavailable "
        send_messages malcolm.onUnavailable s.from  
    end
end

status do |s|
    if s.unsubscribe? 
        log.debug "[Core]: Got unsubscribe"
        send_messages malcolm.onUnsubscribe s.from.stripped.to_s
    elsif s.unavailable?
        log.debug "[Core]: Got unavailable"
        send_messages malcolm.onUnavailable s.from  
    elsif not s.from.stripped.to_s == botUsername
        send_messages malcolm.onStatus s
    end
end

# Message handling
message :chat?, :body do |message| 
    # Message transformation by bots

    # Gistify messages first, if requested
    transformed = gistbot.transformMessage message
    
    # Pass to broadcaster
    send_messages malcolm.onMessage transformed
end

