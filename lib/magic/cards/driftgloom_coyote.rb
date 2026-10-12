module Magic
  module Cards
    DriftgloomCoyote = Creature("Driftgloom Coyote") do
      cost generic: 3, white: 2
      creature_type("Elemental Coyote")
      power 3
      toughness 4
    end

    class DriftgloomCoyote < Creature
      # When this creature enters, exile target creature an opponent controls until this creature leaves the
      # battlefield. If that creature had power 2 or less, put a +1/+1 counter on this creature.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class ExileChoice < Magic::Choice::Targeted
          def choices = battlefield.not_controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            small = target.power <= 2
            actor.exiled_cards << target.card
            trigger_effect(:exile, target: target)
            add_counter("+1/+1", to: actor) if small
          end
        end

        def call
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      # ...until this creature leaves the battlefield: return the exiled card.
      class LeavesTrigger < TriggeredAbility::LeaveTheBattlefield
        def call
          actor.exiled_cards.each do |card|
            card.resolve!(controller: card.owner) if card.zone&.exile?
          end
        end
      end

      def ltb_triggers = [LeavesTrigger]
    end
  end
end
