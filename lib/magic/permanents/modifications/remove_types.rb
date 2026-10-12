module Magic
  module Permanents
    module Modifications
      # "except the token isn't legendary" (Helm of the Host): takes types (here a supertype) away. Layer 4.
      class RemoveTypes < ContinuousEffect
        layer 4

        def initialize(types:, **args)
          @types = types
          super(**args)
        end

        def removed_types
          @types
        end
      end
    end
  end
end
