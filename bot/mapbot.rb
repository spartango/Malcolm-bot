require 'logger'
#require 'blather/stanza/message'

module Bot
    class MapBot
        def initialize()
            @log          = Logger.new(STDOUT)
            @log.level    = Logger::DEBUG
        end

        def generateMapUrl(address)
            return "http://maps.google.com/maps?q=" + ((address.squeeze ' ').gsub ' ', '+')
        end

        # Operates in place
        def transformMessage(message)
            # If we see a message with malcolm map
            #transformed = message.copy()
            # Get the address
            message.body= generateMapUrl (message.body.gsub /malcolm map/i, '') if message.body.match /malcolm map/i
            return message
        end

        def onStatus(fromNodeName)
            # Not interested in status updates
            return []
        end

        def onMessage(incomingMsg)
            reply = transformMessage incomingMsg.reply
            return [reply]
        end

    end
end
