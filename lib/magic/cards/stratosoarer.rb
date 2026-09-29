module Magic
  module Cards
    class Stratosoarer < Creature
      card_name "Stratosoarer"
      cost generic: 4, blue: 1
      creature_type "Elemental"
      power 3
      toughness 5
      keywords :flying
      landcycling({ generic: 1, blue: 1 })

      class GrantChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:grant_keyword, target:, keyword: :flying)
        end
      end

      # "When this creature enters, target creature gains flying until end of turn."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(GrantChoice.new(actor:))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
