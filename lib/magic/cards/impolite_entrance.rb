module Magic
  module Cards
    ImpoliteEntrance = Sorcery("Impolite Entrance") do
      cost red: 1
    end

    class ImpoliteEntrance < Sorcery
      def target_choices
        battlefield.creatures
      end

      def resolve!(target:)
        trigger_effect(:grant_keyword, target: target, keyword: :trample)
        trigger_effect(:grant_keyword, target: target, keyword: :haste)
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end
  end
end
