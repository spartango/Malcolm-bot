require 'set'

module Bot
    class User 
        attr_accessor :name
        attr_reader :resources

        def initialize(node)
            @name      = node
            @resources = Set.new
        end

        def addResource(resource) 
            @resources.add resource
        end

        def removeResource(resource) 
            @resources.delete resource
        end

        def isOnline() 
            return @resources.length > 0
        end

        def to_s() 
            return name+"(x"+@resources.length.to_s+")"
        end
    end
end