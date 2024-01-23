module Magic
  module Permanents
    module Modifications
      class AdditionalType < Modification
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
