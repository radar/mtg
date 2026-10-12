module Magic
  module Cards
    class MindSpring < Sorcery
      card_name "Mind Spring"
      cost x: 1, blue: 2

      def resolve!(value_for_x:)
        draw_cards(value_for_x)
      end
    end
  end
end
