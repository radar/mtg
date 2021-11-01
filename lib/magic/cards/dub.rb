module Magic
  module Cards
    class Dub < Aura
      NAME = "Dub"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      def resolve!
        attach_enchantment = Effects::AttachEnchantment.new(enchantment: self, choices: battlefield.creatures)
        game.add_effect(attach_enchantment)
        super
      end

      def power_buff
        2
      end

      def toughness_buff
        2
      end

      def keyword_grants
        [Card::Keywords::FIRST_STRIKE]
      end

      def type_grants
        ["Knight"]
      end
    end
  end
end
