module Magic
  module Cards
    class Dub < Aura
      card_name "Dub"
      cost "{2}{W}"

      def target_choices
        battlefield.creatures
      end

      def power_modification
        2
      end

      def toughness_modification
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
