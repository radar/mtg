module Magic
  module Effects
    class DealCombatDamage < TargetedEffect
      attr_reader :damage

      def initialize(damage:, **args)
        super(**args)
        @damage = damage
      end

      def resolve!
        target.take_damage(damage)
        game.notify!(
          Events::CombatDamageDealt.new(
            source: source,
            target: target,
            damage: damage,
          )
        )

        if target.player? && source.has_keyword?(Magic::Keywords::Toxic)
          source.trigger_effect(
            :add_counter,
            counter_type: Counters::Poison,
            target: target,
          )
        end

        controller.gain_life(damage) if source.lifelink?
        if target.creature?
          target.mark_for_death! if source.deathtouch?
        end
      end
    end
  end
end
