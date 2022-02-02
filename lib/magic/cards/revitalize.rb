module Magic
  module Cards
    class Revitalize < Instant
      NAME = "Revitalize"
      COST = { generic: 1, white: 1 }

      def resolve!
        game.add_effect(Effects::YouGainLife.new(source: self, life: 3))
        game.add_effect(Effects::DrawCards.new(player: controller))
      end
    end
  end
end
