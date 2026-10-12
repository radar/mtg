module Magic
  module Cards
    ThoughtStalkerWarlock = Creature("Thought-Stalker Warlock") do
      cost generic: 2, black: 1
      creature_type("Lizard Warlock")
      keywords :menace
      power 2
      toughness 2
    end

    class ThoughtStalkerWarlock < Creature
      # When this creature enters, choose target opponent. If they lost life this turn, they reveal their hand,
      # you choose a nonland card from it, and they discard that card. Otherwise, they discard a card.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each do |opponent|
            next if opponent.hand.none?

            if game.current_turn.life_lost_by_player(opponent).positive?
              trigger_effect(:reveal_cards, target: opponent.hand.cards.to_a)
              choice = Magic::Choice::DiscardFromRevealedHand.new(actor: actor, player: opponent, excluded_types: ["Land"])
              game.choices.add(choice) if choice.choices.any?
            else
              game.choices.add(Magic::Choice::Discard.new(actor: actor, player: opponent))
            end
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
