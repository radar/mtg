module Magic
  module Abilities
    module Static
      class TypeGrant < StaticAbility
        attr_reader :source, :applicable_targets

        def self.type_grants(*keywords)
          define_method(:type_grants) { keywords }
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
