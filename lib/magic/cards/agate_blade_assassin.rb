module Magic
  module Cards
    AgateBladeAssassin = Creature("Agate-Blade Assassin") do
      cost generic: 1, black: 1
      creature_type("Lizard Assassin")
      power 1
      toughness 3
    end

    class AgateBladeAssassin < Creature
      # Whenever this creature attacks, defending player loses 1 life and you gain 1 life.
      class AttacksTrigger < TriggeredAbility
        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          attack = event.attacks.find { _1.attacker == actor }
          defender = attack.target.is_a?(Player) ? attack.target : attack.target.controller
          trigger_effect(:lose_life, target: defender, life: 1)
          trigger_effect(:gain_life, life: 1)
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
