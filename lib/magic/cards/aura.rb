module Magic
  module Cards
    class Aura < Card
      attr_reader :attached_to

      def enchant_creature
        attach_enchantment = Effects::AttachEnchantment.new(enchantment: self, choices: battlefield.creatures)
        game.add_effect(attach_enchantment)
      end

      def attach!(target)
        @attached_to = target
        target.attachments << self
      end

      def power_buff
        0
      end

      def toughness_buff
        0
      end

      def keyword_grants
        []
      end

      def type_grants
        []
      end

      def can_activate_ability?(_)
        true
      end
    end
  end
end
