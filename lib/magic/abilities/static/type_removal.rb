module Magic
  module Abilities
    module Static
      class TypeRemoval < StaticAbility
        layer 4

        attr_reader :source, :applicable_targets

        def self.type_removal(*types)
          define_method(:type_removal) { types }
        end

        def applies_to?(target)
          applicable_targets.include?(target)
        end
      end
    end
  end
end
