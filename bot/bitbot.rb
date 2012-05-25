require 'logger'
require 'blather/stanza/message'
require 'bitly'
require 'uri'

module Bot
    class BitBot
        def initialize(username, apiKey)
            @bitly = Bitly.new(username, apiKey)
            @log          = Logger.new(STDOUT)
            @log.level    = Logger::DEBUG
        end

        def shortenUrls(body)
            return body.gsub(URI.regexp) do |url| 
                begin 
                    @bitly.shorten(url).short_url
                rescue
                    url
                end
            end
        end

        def transformMessage(message)
            transformed = message.copy()
            transformed.body= shortenUrls message.body
            return transformed
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