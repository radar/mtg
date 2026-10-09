module Magic
  module Cards
    DwarvenShortsword = Equipment("Dwarven Shortsword") do
      cost generic: 3, white: 1
      equip [Costs::Mana.new(generic: 2)]
    end

    class DwarvenShortsword < Equipment
      class EquippedCreatureBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 1, toughness: 2
        applies_to_target
      end

      def static_abilities = [EquippedCreatureBuff]

      # "When this Equipment enters, create a 2/2 red Dwarf creature token, then attach this Equipment to it."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          token = Array(trigger_effect(:create_token, token_class: Tokens::Dwarf, controller: controller)).flatten.first
          actor.attach_to!(token) if token
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
