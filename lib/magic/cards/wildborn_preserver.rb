module Magic
  module Cards
    WildbornPreserver = Creature("Wildborn Preserver") do
      cost generic: 1, green: 1
      creature_type("Elf Archer")
      keywords :flash, :reach
      power 2
      toughness 2
    end

    class WildbornPreserver < Creature
      class NonTribalCreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          another_creature? && under_your_control? && !event.permanent.type?("Human")
        end

        class PayXChoice < Magic::Choice::PayX
          def resolve!(**args)
            super(**args)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: x)
          end
        end

        def call
          game.choices.add(PayXChoice.new(actor: actor)) if Magic::Choice::PayX.new(actor: actor).can_pay?
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => NonTribalCreatureEntersTrigger }
    end
  end
end
