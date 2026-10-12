module Magic
  module Cards
    BoltHound = Creature("Bolt Hound") do
      cost generic: 2, red: 1
      creature_type "Elemental Dog"
      keywords :haste
      power 2
      toughness 2
    end

    class BoltHound < Creature
      # "Whenever this creature attacks, other creatures you control get +1/+0 until end of turn."
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacker == actor

        def call
          (controller.creatures - [actor]).each do |creature|
            trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 0)
          end
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger }
    end
  end
end
