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

      def power
        base_power +
          @modifiers.sum(&:power) +
          @counters.sum(&:power) +
          @attachments.sum(&:power_modification) +
          static_ability_mods.sum(&:power)
      end

      def toughness
        base_toughness +
          @modifiers.sum(&:toughness) +
          @counters.sum(&:toughness) +
          @attachments.sum(&:toughness_modification) +
          static_ability_mods.sum(&:toughness)
      end

      def modify_power_toughness!(source:, power: 0, toughness: 0)
        game.add_effect(Effects::ApplyPowerToughnessModification.new(
          choices: [self],
          targets: [self],
          source: source,
          power: power,
          toughness: toughness,
        ))
      end

      def take_damage(source:, damage:)
        game.notify!(
          Events::DamageDealt.new(
            source: source,
            target: self,
            damage: damage,
          )
        )
      end

      def receive_notification(event)
        return if !event.respond_to?(:target) || event.target != self

        case event
        when Events::CombatDamageDealt, Events::DamageDealt
          @damage += event.damage
        end
      end

      def fight(target, assigned_damage = power)
        game.notify!(
          Events::CombatDamageDealt.new(source: self, target: target, damage: assigned_damage)
        )
        if target.is_a?(Magic::Player) && has_keyword?(Magic::Keywords::Toxic)
          effect = Effects::AddCounter.new(
            source: self,
            counter_type: Counters::Toxic,
            choices: [target],
            targets: [target]
          )
          game.add_effect(effect)
        end

        controller.gain_life(assigned_damage) if lifelink?
        if target.is_a?(Creature)
          target.mark_for_death! if deathtouch?
        end
      end

      def attacking?
        game.current_turn.attacking?(self)
      end

      def static_ability_mods
        game.battlefield.static_abilities.of_type(Abilities::Static::PowerAndToughnessModification).applies_to(self)
      end
    end
  end
end
