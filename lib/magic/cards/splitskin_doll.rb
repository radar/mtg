module Magic
  module Cards
    SplitskinDoll = Creature("Splitskin Doll") do
      cost generic: 1, white: 1
      artifact_creature_type "Toy"
      power 2
      toughness 1
    end

    class SplitskinDoll < Creature
      # "When this creature enters, draw a card. Then discard a card unless you control another creature with power
      # 2 or less."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          draw_card
          return if controller.creatures.any? { _1 != actor && _1.power <= 2 }

          game.choices.add(Magic::Choice::Discard.new(actor:, player: controller)) if hand.any?
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
