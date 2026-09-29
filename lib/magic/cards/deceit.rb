module Magic
  module Cards
    class Deceit < Creature
      card_name "Deceit"
      cost "{4}{U/B}{U/B}"
      creature_type "Elemental Incarnation"
      power 5
      toughness 5
      evoke "{U/B}{U/B}"

      # "... return up to one other target nonland permanent to its owner's hand."
      class BounceChoice < Magic::Choice::Targeted
        def choices = battlefield.nonland.except(actor)

        def choice_amount = 0..1

        def resolve!(target:) = target.return_to_hand
      end

      # "When this creature enters, if {U}{U} was spent to cast it, return up to one other target
      # nonland permanent to its owner's hand."
      class BlueTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:blue, 2)

        def call
          choice = BounceChoice.new(actor:)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "... You choose a nonland card from it. That player discards that card."
      class DiscardChoice < Magic::Choice
        def initialize(actor:, player:)
          super(actor:)
          @player = player
        end

        def choices = @player.hand.cards.reject(&:land?)

        def resolve!(target:) = target.discard!
      end

      class OpponentChoice < Magic::Choice::Targeted
        def choices = game.opponents(controller)

        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:reveal_cards, target: target.hand.cards)
          choice = DiscardChoice.new(actor:, player: target)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      # "When this creature enters, if {B}{B} was spent to cast it, target opponent reveals their
      # hand. You choose a nonland card from it. That player discards that card."
      class BlackTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = super && actor.mana_spent?(:black, 2)

        def call
          game.add_choice(OpponentChoice.new(actor:))
        end
      end

      def etb_triggers = [BlueTrigger, BlackTrigger]
    end
  end
end
