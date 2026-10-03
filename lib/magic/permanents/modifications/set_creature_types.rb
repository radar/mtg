module Magic
  module Permanents
    module Modifications
      # "~ becomes a Werewolf." (Mild-Mannered Librarian): its creature types are replaced by these (rule 205.1b),
      # keeping its other types. The latest one wins; unlike AdditionalType it doesn't add to the old ones.
      class SetCreatureTypes < ContinuousEffect
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
