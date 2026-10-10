module Magic
  module Cards
    EnduringVitality = Creature("Enduring Vitality") do
      cost generic: 1, green: 2
      enchantment_creature_type("Elk Glimmer")
      keywords :vigilance
      power 3
      toughness 3
    end

    class EnduringVitality < Creature
      # "{T}: Add one mana of any color."
      class AnyColorManaAbility < Magic::TapManaAbility
        choices :all
      end

      # "Creatures you control have '{T}: Add one mana of any color.'"
      class GrantManaAbility < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent)
          permanent.creature? && permanent.controller == controller
        end

        def granted_abilities = [AnyColorManaAbility]
      end

      def static_abilities = [GrantManaAbility]

      def death_triggers = [TriggeredAbility::EnduringReturn]
    end
  end
end
