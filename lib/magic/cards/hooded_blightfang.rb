module Magic
  module Cards
    HoodedBlightfang = Creature("Hooded Blightfang") do
      cost generic: 2, black: 1
      creature_type "Snake"
      keywords :deathtouch
      power 1
      toughness 4
    end

    class HoodedBlightfang < Creature
      # "Whenever a creature you control with deathtouch attacks, each opponent loses 1 life and you gain 1 life."
      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attacker.controller == controller && event.attacker.deathtouch?
        end

        def call
          opponents.each { |opponent| trigger_effect(:lose_life, target: opponent, life: 1) }
          trigger_effect(:gain_life, life: 1)
        end
      end

      # "Whenever a creature you control with deathtouch deals damage to a planeswalker, destroy that planeswalker."
      class DamageTrigger < TriggeredAbility
        def should_perform?
          source = event.source
          source.respond_to?(:deathtouch?) && source.creature? && source.controller == controller &&
            source.deathtouch? && event.target.respond_to?(:planeswalker?) && event.target.planeswalker?
        end

        def call
          trigger_effect(:destroy_target, target: event.target)
        end
      end

      def event_handlers = { Events::CreatureAttacked => AttacksTrigger, Events::DamageDealt => DamageTrigger }
    end
  end
end
