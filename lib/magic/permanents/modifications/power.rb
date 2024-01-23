module Magic
  module Permanents
    module Modifications
      class Power < Modification
        def initialize(power:, **args)
          @power = power
          super(**args)
        end
      end
    end
  end
end
