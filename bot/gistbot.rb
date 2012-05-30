require 'logger'
require 'blather/stanza/message'
require 'activegist'

module Bot
    class GistBot
        def initialize(username=nil, password=nil)
            ActiveGist::API.username = username
            ActiveGist::API.password = password
            @log          = Logger.new(STDOUT)
            @log.level    = Logger::DEBUG
        end

        def gistify(body)
            gist = ActiveGist.create!(:files => { 'body' => { :content => body } })
            return gist.html_url if gist.html_url 
            # Otherwise couldn't gistify it
            return body
        end

        # Operates in place
        def transformMessage(message)
            # Look for the gist directive
            # Gotta strip off the directive
            #transformed = message.copy()
            message.body= gistify (message.body.gsub /^malcolm gist/i, '') if message.body.match /^malcolm gist/i
            return message
        end

        def onStatus(fromNodeName)
            return []
        end

        def onMessage(incomingMsg)
            # Reply with shortened Urls
            reply = transformMessage incomingMsg.reply
            return [reply]
        end
    end
end