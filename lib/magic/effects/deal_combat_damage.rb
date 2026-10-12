module Magic
  module Effects
    class DealCombatDamage < TargetedEffect
      attr_reader :damage

      def initialize(damage:, **args)
        super(**args)
        @damage = damage
      end

      def resolve!
        return if damage_prevented?
        return if game.current_turn.combat_damage_prevented_from?(source)

        if target.player? && source.has_keyword?(Magic::Keywords::Toxic)
          source.trigger_effect(
            :add_counter,
            counter_type: "poison",
            target: target,
          )
          deal_combat_damage!

        elsif target.player? && source.has_keyword?(Magic::Keywords::INFECT)
          source.trigger_effect(
            :add_counter,
            counter_type: "poison",
            target: target,
            amount: damage,
          )
        else
          deal_combat_damage!
        end

        controller.gain_life(damage) if source.lifelink?
        if target.creature?
          target.mark_for_death! if source.deathtouch?
        end
      end

      def deal_combat_damage!
        deal_damage_to_target!(target, damage)

        game.notify!(
          Events::DamageDealt.new(
            source: source,
            target: target,
            damage: damage,
            combat: true,
            infect: source.has_keyword?(Magic::Keywords::INFECT),
          )
        )

        game.notify!(
          Events::CombatDamageDealt.new(
            source: source,
            target: target,
            damage: damage,
          )
        )
      end
    end
  end
end
