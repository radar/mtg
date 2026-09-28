module Magic
  module Permanents
    module Modifications
      class Toughness < ContinuousEffect
        layer 7, sublayer: :c

        def initialize(toughness_modification:, **args)
          @toughness_modification = toughness_modification
          super(**args)
        end
      end
    end
  end
end
