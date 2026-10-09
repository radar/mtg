module Magic
  module Cards
    WilderlandScrounger = Creature("Wilderland Scrounger") do
      cost generic: 4, green: 1
      creature_type "Wolf"
      power 3
      toughness 6
    end

    class WilderlandScrounger < Creature
      # "Ferocious -- Whenever this creature attacks while you control a creature with power 4 or greater, put a +1/+1
      # counter on each creature you control."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && controller.creatures.any? { _1.power >= 4 }
        end

        def call
          controller.creatures.each { |creature| trigger_effect(:add_counter, counter_type: "+1/+1", target: creature, amount: 1) }
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
