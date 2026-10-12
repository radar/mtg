module Magic
  module Cards
    StarscapeCleric = Creature("Starscape Cleric") do
      cost generic: 1, black: 1
      creature_type("Bat Cleric")
      keywords :flying
      power 2
      toughness 1
      offspring generic: 2, black: 1
    end

    class StarscapeCleric < Creature
      # This creature can't block.
      def can_block?(_attacker) = false

      # Whenever you gain life, each opponent loses 1 life.
      class LifeGainTrigger < TriggeredAbility
        def should_perform? = event.player == controller

        def call
          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: 1) }
        end
      end

      def event_handlers = super.merge(Events::LifeGain => LifeGainTrigger)
    end
  end
end
