module Magic
  module Cards
    LunarInsight = Sorcery("Lunar Insight") do
      cost generic: 2, blue: 1
    end

    class LunarInsight < Sorcery
      def resolve!
        draw_cards(controller.permanents.reject(&:land?).map(&:mana_value).uniq.count)
      end
    end
  end
end
