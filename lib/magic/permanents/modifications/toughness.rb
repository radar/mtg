module Magic
  module Permanents
    module Modifications
      class Toughness < Modification
        def initialize(toughness:, **args)
          @toughness = toughness
          super(**args)
        end
      end
    end
  end
end
