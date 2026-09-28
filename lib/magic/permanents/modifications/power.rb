module Magic
  module Permanents
    module Modifications
      class Power < ContinuousEffect
        layer 7, sublayer: :c

        def initialize(power_modification:, **args)
          @power_modification = power_modification
          super(**args)
        end
      end
    end
  end
end
