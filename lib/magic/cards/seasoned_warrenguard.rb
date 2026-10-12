module Magic
  module Cards
    SeasonedWarrenguard = Creature("Seasoned Warrenguard") do
      cost white: 1
      creature_type("Rabbit Warrior")
      power 1
      toughness 2
    end

    class SeasonedWarrenguard < Creature
      # Whenever this creature attacks while you control a token, this creature gets +2/+0 until end of turn.
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { _1.attacker == actor } && battlefield.controlled_by(controller).any?(&:token?)
        end

        def call
          pump(actor, 2, 0)
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
