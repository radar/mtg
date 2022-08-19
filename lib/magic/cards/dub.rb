module Magic
  module Cards
    class Dub < Aura
      NAME = "Dub"
      TYPE_LINE = "Enchantment -- Aura"
      COST = { generic: 2, white: 1 }

      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        enchant_creature(target: target)
        super(controller)
      end

      def power_buff
        2
      end

      def toughness_buff
        2
      end

      def keyword_grants
        [Keywords::FIRST_STRIKE]
      end

      def type_grants
        ["Knight"]
      end
    end
  end
end
