module Magic
  module Permanents
    module Modifications
      class BaseToughness < Modification
        attr_reader :base_toughness

        def initialize(base_toughness: 0, **args)
          @base_toughness = base_toughness
          super(**args)
        end
      end
    end
  end
end
