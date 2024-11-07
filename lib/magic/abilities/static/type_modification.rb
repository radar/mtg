module Magic
  module Abilities
    module Static
      class TypeModification < StaticAbility
        attr_reader :source, :applicable_targets
        def initialize(source:)
          @source = source
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
