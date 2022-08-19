module Magic
  module Cards
    class Creature < Card
      attr_reader :base_power, :base_toughness

      POWER = 0
      TOUGHNESS = 0

      def initialize(**args)
        @base_power = self.class::POWER
        @base_toughness = self.class::TOUGHNESS
        super(**args)
      end

      def can_attack?
        @attachments.all?(&:can_attack?)
      end

      def can_block?
        @attachments.all?(&:can_block?)
      end

      def whenever_this_attacks
      end

      def cleanup!
        until_eot_modifiers = modifiers.select(&:until_eot?)
        until_eot_modifiers.each { |modifier| modifiers.delete(modifier) }

        super
      end
    end
  end
end
