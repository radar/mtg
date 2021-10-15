module Magic
  module Cards
    class Dub < Card
      NAME = "Dub"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      class DubAura < Aura
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

      def resolve!
        attach_enchantment = Effects::AttachEnchantment.new(enchantment: DubAura.new, choices: game.battlefield.creatures)
        game.add_effect(attach_enchantment)
      end
    end
  end
end
