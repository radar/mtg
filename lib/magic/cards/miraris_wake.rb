module Magic
  module Cards
    MirarisWake = Enchantment("Mirari's Wake") do
      cost generic: 3, green: 1, white: 1
    end

    class MirarisWake < Enchantment
      class PowerAndToughnessModification < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 1

        applicable_targets { your.creatures }
      end

      class ManaDoubler < StaticAbility
        def additional_mana(source, mana)
          return unless source.land? && source.controller == controller

          controller.add_mana(**mana)
        end
      end

      def static_abilities = [PowerAndToughnessModification, ManaDoubler]
    end
  end
end