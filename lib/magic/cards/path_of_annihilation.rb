module Magic
  module Cards
    PathOfAnnihilation = Enchantment("Path of Annihilation") do
      cost generic: 3, green: 1
      keywords :devoid
    end

    class PathOfAnnihilation < Enchantment
      # "When this enchantment enters, create two 0/1 colorless Eldrazi Spawn creature tokens..."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call = create_eldrazi_spawn(2)
      end

      # "{T}: Add one mana of any color."
      class AnyColorManaAbility < Magic::TapManaAbility
        choices :all
      end

      # "Eldrazi you control have '{T}: Add one mana of any color.'"
      class GrantManaAbility < Abilities::Static::GrantActivatedAbilities
        def applies_to?(permanent) = permanent.controller == controller && permanent.type?("Eldrazi")

        def granted_abilities = [AnyColorManaAbility]
      end

      # "Whenever you cast a creature spell with mana value 7 or greater, you gain 4 life."
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform? = you? && spell.creature? && spell.mana_value >= 7

        def call = gain_life(4)
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [GrantManaAbility]
      def event_handlers = super.merge(Events::SpellCast => SpellCastTrigger)
    end
  end
end
