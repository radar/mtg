module Magic
  module Cards
    FanaticOfTheHarrowing = Creature("Fanatic of the Harrowing") do
      cost generic: 3, black: 1
      creature_type "Human Cleric"
      power 2
      toughness 2
    end

    class FanaticOfTheHarrowing < Creature
      # The controller's discard: "If you discarded a card this way, draw a card."
      class DiscardAndDraw < Magic::Choice::Discard
        def resolve!(card: nil, cards: nil)
          super
          player.draw!
        end
      end

      # "When this creature enters, each player discards a card. If you discarded a card this way, draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.players.each do |player|
            next if player.hand.empty?

            choice_class = player == controller ? DiscardAndDraw : Magic::Choice::Discard
            game.add_choice(choice_class.new(player: player, actor: actor))
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
