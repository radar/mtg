module Magic
  module Cards
    ChampionsOfTheShoal = Creature("Champions of the Shoal") do
      cost generic: 3, blue: 1
      creature_type("Merfolk Soldier")
      power 4
      toughness 6
    end

    class ChampionsOfTheShoal < Creature
      # As an additional cost to cast this spell, behold a Merfolk and exile it.
      def additional_costs
        [Costs::Behold.new(self, type: "Merfolk", exile: true)]
      end

      # Whenever this creature enters or becomes tapped, tap up to one target creature and put a
      # stun counter on it.
      module StunTarget
        class TargetChoice < Magic::Choice::Targeted
          def choices = battlefield.creatures

          def choice_amount = 0..1

          def resolve!(target:)
            trigger_effect(:tap, target: target)
            trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 1)
          end
        end

        def call
          choice = TargetChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        include StunTarget
      end

      class BecomesTappedTrigger < TriggeredAbility
        include StunTarget

        def should_perform?
          event.permanent == actor
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers = { Events::PermanentTapped => BecomesTappedTrigger }

      # When this creature leaves the battlefield, return the exiled card to its owner's hand.
      def ltb_triggers = [Behold::ReturnExiledCardTrigger]
    end
  end
end
