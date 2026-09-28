module Magic
  module Permanents
    module Modifications
      class AdditionalType < ContinuousEffect
        layer 4

        def initialize(types:, **args)
          @types = types
          super(**args)
        end

        def type_grants
          @types
        end
      end
    end
  end
end
