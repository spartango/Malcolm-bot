require 'logger'
require 'blather/stanza/message'
require './bot/bitbot'
require './bot/gistbot'

module Bot
    class Malcolm 
        def initialize(bitbot, gistbot)
            @bitbot = bitbot
            @gistbot = gistbot
            @participants = []
            @log          = Logger.new(STDOUT)
            @log.level    = Logger::DEBUG
        end

        def buildMessage(user, body) 
            return Blather::Stanza::Message.new user, body
        end

        # Creates a bunch of messages to be sent to a group of users
        def broadcastMessage(targets, body) 
            return targets.map { |targetUser|
                # Make new message & Append sender name
                buildMessage targetUser, body
            }
        end

        # Applies transforms to a given message
        def transformMessage(message) 
            # Gistify messages first, if requested
            # Turn urls into bitly urls
            transformed = @gistbot.transformMessage message
            transformed = @bitbot.transformMessage transformed
            return transformed
        end

        # Events
        def onStatus(fromNodeName)
            if not @participants.include? fromNodeName
                @log.debug "[Malcolm]: tracking "+fromNodeName.to_s
                @participants << fromNodeName
                return [(buildMessage fromNodeName, ("Malcolm: Welcome "+fromNodeName.node.to_s))]
            end
            return []
        end

        def onQuery(message)
            # Malcolm Queries
            senderName = message.from.node.to_s
            # Global
            #if message.body.match /hey/i or message.body.match /hello/i or message.body.match /hi/i
                # Just a greeting
            #    return broadcastMessage @participants, ("Malcolm: Hello "+senderName)
            if message.body.match /who'?s here/
                # Who's here 
                return broadcastMessage @participants, ("Malcolm: "+@participants.join(', ')+" here")

            elsif message.body.match /time/
                # Time 
                return broadcastMessage @participants, ("Malcolm: "+senderName+", the time is "+Time.now.strftime("%H:%M:%S"))

            # Personal
            elsif message.body.match /leave/ or message.body.match /pause/ 
                # Pause / Leave
                @participants.delete message.from.stripped
                return broadcastMessage @participants, ("Malcolm: Goodbye, "+senderName)
            
            elsif message.body.match /thank/i
                return broadcastMessage @participants, "Malcolm: You're welcome, "+senderName

            elsif message.body.match /help/i
                return broadcastMessage(@participants, ("Malcolm: Greetings " +senderName+", my name is Malcolm, and I coordinate this chatroom. I can tell you who's here, the time, or remove you from the room"))

            #else
                # Default / Give up
            #    return broadcastMessage @participants, "Malcolm: Sorry? Is there a way I can help?"
            end
            return []
        end

        def onMessage(incomingMsg)
            # Status Guard
            statusMsgs = onStatus incomingMsg.from.stripped

            # Transformation
            message = transformMessage incomingMsg

            # Query handling
            queryMsgs = []
            if message.body.match /Malcolm/i
                queryMsgs = onQuery message
            end

            # Broadcast
            @log.debug "[Malcolm]: broadcasting message from "+ message.from.to_s
            targets = @participants.select{ |user| user != message.from.stripped }
            broadcastMsgs = broadcastMessage targets, (message.from.node.to_s + ": " + message.body)

            return statusMsgs + broadcastMsgs + queryMsgs
        end

    end
end