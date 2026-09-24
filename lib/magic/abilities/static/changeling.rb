module Magic
  module Abilities
    module Static
      # Rule 702.73a: Changeling is a characteristic-defining ability meaning
      # "This object is every creature type." It works in every zone, so
      # Card#types also consults it (see Card#types).
      class Changeling < TypeGrant
        def initialize(source:)
          @source = source
        end

        def type_grants
          Types::Creatures.values
        end

        def applicable_targets
          [source]
        end
      end
    end
  end
end
