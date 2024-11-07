module Magic
  module Permanents
    module Modifications
      class Toughness < Modification
        def initialize(toughness_modification:, **args)
          @toughness_modification = toughness_modification
          super(**args)
        end
      end
    end
  end
end
