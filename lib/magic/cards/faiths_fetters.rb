module Magic
  module Cards
    class FaithsFetters < Card
      NAME = "Faith's Fetters"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      class Aura < Magic::Aura
        def can_attack?
          false
        end

        def can_block?
          false
        end
      end

      def resolve!
        controller.gain_life(4)
        attach_enchantment = Effects::AttachEnchantment.new(enchantment: Aura.new, choices: game.battlefield.creatures)
        game.add_effect(attach_enchantment)
        super
      end
    end
  end
end
