module Magic
  module Cards
    ValleyRotcaller = Creature("Valley Rotcaller") do
      cost generic: 1, black: 1
      creature_type("Squirrel Warlock")
      keywords :menace
      power 1
      toughness 3
    end

    class ValleyRotcaller < Creature
      # Whenever this creature attacks, each opponent loses X life and you gain X life, where X is the number
      # of other Squirrels, Bats, Lizards, and Rats you control.
      class AttacksTrigger < TriggeredAbility
        TYPES = %w[Squirrel Bat Lizard Rat].freeze

        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          x = (battlefield.controlled_by(controller).creatures - [actor]).count { |creature| TYPES.any? { creature.type?(_1) } }
          return if x.zero?

          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: x) }
          trigger_effect(:gain_life, life: x)
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
