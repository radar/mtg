module Magic
  module Cards
    SunTitan = Creature("Sun Titan") do
      cost generic: 4, white: 2
      creature_type "Giant"
      keywords :vigilance
      power 6
      toughness 6
    end

    class SunTitan < Creature
      # "you may return target permanent card with mana value 3 or less from your graveyard to the battlefield."
      class ReturnChoice < Magic::Choice::Targeted
        def prompt = "Return a permanent card with mana value 3 or less from your graveyard to the battlefield."

        def targets? = false

        def choices
          controller.graveyard.cards.select { |card| card.permanent? && card.mana_value <= 3 }
        end

        def choice_amount = 1

        def resolve!(target:)
          target.return_to_battlefield!
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = ReturnChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacker == actor
        end

        def call
          choice = ReturnChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      def event_handlers
        super.merge(Events::EnteredTheBattlefield => EntersTrigger, Events::CreatureAttacked => AttackTrigger)
      end
    end
  end
end
