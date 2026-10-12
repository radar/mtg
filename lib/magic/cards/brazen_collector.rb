module Magic
  module Cards
    BrazenCollector = Creature("Brazen Collector") do
      cost generic: 1, red: 1
      creature_type("Raccoon Rogue")
      keywords :first_strike
      power 2
      toughness 1
    end

    class BrazenCollector < Creature
      # Whenever this creature attacks, add {R}. Until end of turn, you don't lose this mana as steps and
      # phases end. (A player's mana pool is not emptied between steps in this engine.)
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          controller.add_mana(red: 1)
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
