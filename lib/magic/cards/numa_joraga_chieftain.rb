module Magic
  module Cards
    NumaJoragaChieftain = Creature("Numa, Joraga Chieftain") do
      legendary_creature_type "Elf Warrior"
      cost generic: 2, green: 1
      power 2
      toughness 2
    end

    class NumaJoragaChieftain < Creature
      class DistributeCountersChoice < Magic::Choice
        def initialize(actor:, amount:)
          @amount = amount
          super(actor: actor)
        end

        def choices
          game.battlefield.creatures.by_any_type("Elf")
        end

        def resolve!(distribution:)
          distribution.each do |target, amount|
            amount.times { trigger_effect(:add_counter, counter_type: "+1/+1", target: target) }
          end
        end
      end

      class MayPayChoice < Magic::Choice::May
        def resolve!(x:, payment: {})
          return if x <= 0

          controller.pay_mana(payment)
          game.choices.add(DistributeCountersChoice.new(actor: actor, amount: x))
        end
      end

      class CombatTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          game.choices.add(MayPayChoice.new(actor: actor))
        end
      end

      def event_handlers
        {
          Events::BeginningOfCombat => CombatTrigger
        }
      end
    end
  end
end
