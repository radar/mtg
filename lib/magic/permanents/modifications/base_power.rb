module Magic
  module Permanents
    module Modifications
      class BasePower < Modification
        attr_reader :base_power

        def initialize(base_power: 0, **args)
          @base_power = base_power
          super(**args)
        end
      end
    end
  end
end
