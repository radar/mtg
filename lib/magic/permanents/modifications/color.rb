module Magic
  module Permanents
    module Modifications
      class Color < ContinuousEffect
        layer 5

        attr_reader :colors

        def initialize(colors:, **args)
          @colors = colors
          super(**args)
        end
      end
    end
  end
end
