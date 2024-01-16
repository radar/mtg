module Magic
  module Permanents
    class Creature < Permanent
      attr_reader :damage

      class PowerToughnessModification
        attr_reader :power, :toughness, :until_eot

        def initialize(power: 0, toughness: 0, until_eot: true, **args)
          super(**args)
          @power = power
          @toughness = toughness
          @until_eot = until_eot
        end

        def until_eot?
          @until_eot
        end
      end

      def initialize(**args)
        super(**args)
        @damage = 0
      end

      def inspect
        "#<Magic::Permanent::Creature name:#{card.name} controller:#{controller.name}>"
      end

      def mark_for_death!
        @marked_for_death = true
      end

      def dead?
        @marked_for_death || !alive? || zone.nil?
      end

      def base_power
        @card.base_power
      end

      def base_toughness
        @card.base_toughness
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

      def modify_power!(amount)
        modify_power_toughness!(power: amount)
      end

      def modify_power_toughness!(power: 0, toughness: 0)
        @modifiers << PowerToughnessModification.new(power:, toughness:)
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
        super

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

      def can_attack?
        attachments.all?(&:can_attack?)
      end

      def can_block?
        attachments.all?(&:can_block?)
      end

      def cleanup!
        until_eot_modifiers = modifiers.select(&:until_eot?)
        until_eot_modifiers.each { |modifier| modifiers.delete(modifier) }

        super
      end

      def static_ability_mods
        game.battlefield.static_abilities.of_type(Abilities::Static::PowerAndToughnessModification).applies_to(self)
      end
    end
  end
end
