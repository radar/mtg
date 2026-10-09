module Magic
  module Cards
    Wargling = Creature("Wargling") do
      cost generic: 1, green: 1
      creature_type "Wolf"
      power 2
      toughness 2
    end

    class Wargling < Creature
      # "Ferocious -- Whenever this creature attacks while you control a creature with power 4 or greater, until end of
      # turn, this creature gets +1/+0 and creatures you control gain trample."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && controller.creatures.any? { _1.power >= 4 }
        end

        def call
          trigger_effect(:modify_power_toughness, target: actor, power: 1, toughness: 0)
          controller.creatures.each { |creature| trigger_effect(:grant_keyword, target: creature, keyword: :trample) }
        end
      end

      def event_handlers = super.merge({ Events::FinalAttackersDeclared => AttacksTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
