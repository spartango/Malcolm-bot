require 'logger'
require 'blather/stanza/message'

module Bot
    class Malcolm 
        def initialize()
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
            if message.body.match /hey/ or message.body.match /hello/
                # Just a greeting
                return broadcastMessage @participants, ("Malcolm: Hello "+senderName)
            elsif message.body.match /whos here/
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
            else
                # Default / Give up
                return broadcastMessage @participants, "Malcolm: Sorry "+senderName+", I can't help you with that."
            end

        end

        def onMessage(message)
            # Status Guard
            statusMsgs = onStatus(message.from.stripped)

            # Query handling
            queryMsgs = []
            if message.body.match /Malcolm/ or message.body.match /malcolm/
                queryMsgs = onQuery(message)
            end

            # Broadcast
            @log.debug "[Malcolm]: broadcasting message from "+ message.from.to_s
            targets = @participants.select{ |user| user != message.from.stripped }
            broadcastMsgs = broadcastMessage targets, (message.from.node.to_s + ": " + message.body)

            return statusMsgs + broadcastMsgs + queryMsgs
        end

    end
end