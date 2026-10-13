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
        give_keyword(target, :trample)
        give_keyword(target, :haste)
        draw_card
      end
    end
  end
end
