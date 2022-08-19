module Magic
  module Permanents
    class Creature < Permanent
      attr_reader :damage

      class Buff
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

      def dead?
        @marked_for_death || !alive?
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
          @attachments.sum(&:power_buff) +
          static_ability_buffs.sum(&:power)
      end

      def toughness
        base_toughness +
          @modifiers.sum(&:toughness) +
          @counters.sum(&:toughness) +
          @attachments.sum(&:toughness_buff) +
          static_ability_buffs.sum(&:toughness)
      end

      def take_damage(damage_dealt)
        @damage += damage_dealt
      end

      def fight(target, assigned_damage = power)
        game.notify!(
          Events::DamageDealt.new(source: self, target: target, damage: assigned_damage)
        )
        controller.gain_life(assigned_damage) if lifelink?
        if target.is_a?(Creature)
          target.mark_for_death! if deathtouch? || target.dead?
        end
      end


      def add_counter(counter_type, amount: 1)
        amount.times do
          @counters << counter_type.new
        end
      end

      def static_ability_buffs
        game.battlefield.static_abilities.of_type(Abilities::Static::CreaturesGetBuffed).applies_to(self)
      end
    end
  end
end