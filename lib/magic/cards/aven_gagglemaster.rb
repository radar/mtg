module Magic
  module Cards
    AvenGagglemaster = Creature("Aven Gagglemaster") do
      cost generic: 3, white: 2
      type "Creature -- Bird Warror"
      power 4
      toughness 3
      keywords Keywords::FLYING
    end

    class AvenGagglemaster < Creature
      def entered_the_battlefield!
        flying_creatures = game.battlefield
          .creatures
          .controlled_by(controller)
          .select(&:flying?)


        controller.gain_life(2 * flying_creatures.count)
      end
    end
  end
end
