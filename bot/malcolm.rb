require 'logger'
require 'blather/stanza/message'
require 'blather/stanza/presence/status'

require './bot/user'

module Bot
    class Malcolm 
        def initialize(allowed)
            @participants = {}
            @allowed      = allowed
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

        def onlineParticipants()
            return @participants.values.select { |user|  
                user.isOnline
            }
        end

        def getUser(from) 
            user = @participants[from.stripped.to_s] 
            if not user
                user = onNewUser(from)
            end
            return user
        end

        def onNewUser(from)
            @log.debug "[Malcolm]: New User..."
            if (not @allowed) or @allowed.include? from.stripped.to_s
                newUser = User.new from.node.to_s
                @participants[from.stripped.to_s] = newUser
                @log.debug "[Malcolm]: Added "+newUser.name
                return newUser 
            else 
                @log.debug "[Malcolm]: User rejected"
                return nil
            end
        end

        def onSubscribe(request)
            newUser = onNewUser(request.from)

            if newUser
                # Send the approval
                write_to_stream request.approve!
                return broadcastMessage @participants.keys, "Welcome "+newUser.name+" to the chat."
            else
                # Send the refusal
                write_to_stream request.refuse!
                return []
            end

        end

        def onUnsubscribe(user) 
            if @participants.include user
                messages = broadcastMessage @participants.keys, @participants[user].name+" has left."
                @participants.delete user
                return messages
            end
            return []
        end

        def onUnavailable(from)
            user = getUser from
            user.removeResource from.resource.to_s if user
            return []
        end

        def onStatus(status)
            user = getUser status.from
            user.addResource status.from.resource.to_s if user

            # Set the status message to be the list of active users
            status = Blather::Stanza::Presence::Status.new
            status.message = self.onlineParticipants.join(', ')
            return [status]
        end

        def onQuery(message, user)
            # Malcolm Queries
            # Global
            if message.body.match /who'?s here/
                # Who's here 
                return broadcastMessage @participants.keys, ("Malcolm: "+self.onlineParticipants.join(', ')+" are here.")

            elsif message.body.match /time/
                # Time 
                return broadcastMessage @participants.keys, ("Malcolm: "+user.name+", the time is "+Time.now.strftime("%H:%M:%S")+".")
    
            elsif message.body.match /thank/i
                return broadcastMessage @participants.keys, "Malcolm: You're welcome, "+user.name+"."

            elsif message.body.match /help/i
                return broadcastMessage(@participants.keys, ("Malcolm: Greetings " +user.name+", my name is Malcolm, and I coordinate this chatroom. I can tell you who's here, the time, or set your name."))
            
            # Set Name
            elsif message.body.match /name/i
                # Grab the last word
                parts = message.body.split(' ')
                user.name = parts[parts.length - 1] if parts.length > 0
                return broadcastMessage @participants.keys, "Malcolm: Ok, I'll call you "+user.name+" from now on."
            
            elsif message.body.match /allowed/i
                # Who's here 
                return broadcastMessage @participants.keys, ("Malcolm: "+@allowed.join(', ')+" are allowed to join.") if @allowed

                # Otherwise
                return broadcastMessage @participants.keys, "Malcolm: Anyone may join."

            # Add to allowed 
            elsif @allowed and message.body.match /allow/i
                # Grab the last word
                parts = message.body.split(' ')
                @allowed << parts[parts.length - 1] if @allowed and parts.length > 0
                return broadcastMessage @participants.keys, "Malcolm: Ok, I'll allow "+parts[parts.length - 1]+" to join."
            end

            return []
        end

        def onMessage(message)
            user = getUser message.from

            if user
                # Query handling
                queryMsgs = []
                if message.body.match /Malcolm/i
                    queryMsgs = onQuery message, user
                end

                # Broadcast
                targets = @participants.keys.select{ |user| user != message.from.stripped.to_s }
                broadcastMsgs = broadcastMessage targets, (user.name + ": " + message.body)

                return broadcastMsgs + queryMsgs
            end 

            return []
        end

    end
end