module Magic
  module Cards
    PlumecreedEscort = Creature("Plumecreed Escort") do
      cost generic: 1, blue: 1
      creature_type "Bird Scout"
      keywords :flash, :flying
      power 2
      toughness 1
    end

    class PlumecreedEscort < Creature
      # "target creature you control gains hexproof until end of turn."
      class HexproofChoice < Magic::Choice::Targeted
        def choices = controller.creatures
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:grant_keyword, target: target, keyword: :hexproof)
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(HexproofChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
