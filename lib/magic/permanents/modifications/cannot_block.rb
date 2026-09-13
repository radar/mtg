module Magic
  module Permanents
    module Modifications
      class CannotBlock
        attr_reader :until_eot

        def initialize(until_eot: true)
          @until_eot = until_eot
        end

        def until_eot?
          @until_eot
        end
      end
    end
  end
end
