module Magic
  module Cards
    KitesailFreebooter = Creature("Kitesail Freebooter") do
      cost generic: 1, black: 1
      creature_type "Human Pirate"
      keywords :flying
      power 1
      toughness 2
    end

    class KitesailFreebooter < Creature
      # "You choose a noncreature, nonland card from it. Exile that card until this creature leaves the battlefield."
      # Taking none (no legal card) is `game.skip_choice!`. The opponent's hand is revealed first.
      class ExileChoice < Magic::Choice::Targeted
        attr_reader :opponent

        def initialize(actor:, opponent:)
          @opponent = opponent
          super(actor:)
        end

        def choices = opponent.hand.cards.reject { |card| card.creature? || card.land? }
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:exile, target:)
          actor.exiled_cards << target
        end
      end

      # "When this creature enters, target opponent reveals their hand."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each do |opponent|
            trigger_effect(:reveal_cards, target: opponent.hand.cards) if opponent.hand.any?
            choice = ExileChoice.new(actor:, opponent:)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      # The exiled card returns to its owner's hand when this creature leaves the battlefield.
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def call
          actor.exiled_cards.each { |card| card.move_to_hand!(card.owner) }
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
