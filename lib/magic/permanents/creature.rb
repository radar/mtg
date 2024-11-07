module Magic
  module Permanents
    module Creature
      attr_reader :damage

      def inspect
        "#<Magic::Permanent::Creature name:#{card.name} controller:#{controller.name}>"
      end

      def creature?
        type?(T::Creature)
      end

      def mark_for_death!
        @marked_for_death = true
      end

      def dead?
        @marked_for_death || !alive? || zone.nil?
      end

      def base_power
        base_power = @card.respond_to?(:base_power) ? @card.base_power : 0
        base_power_modifier = @modifiers.select { |mod| mod.is_a?(Modifications::BasePower) }.last
        base_power_modifier ? base_power_modifier.base_power : base_power
      end

      def base_toughness
        base_toughness = @card.respond_to?(:base_toughness) ? @card.base_toughness : 0
        base_toughness_modifier = @modifiers.select { |mod| mod.is_a?(Modifications::BaseToughness) }.last
        base_toughness_modifier ? base_toughness_modifier.base_toughness : base_toughness
      end

      def take_damage(damage)
        @damage += damage
      end

      def fight(target, assigned_damage = power)
        trigger_effect(:deal_combat_damage, source: self, target: target, damage: assigned_damage)
      end

      def attacking?
        game.current_turn.attacking?(self)
      end
    end
  end
end
