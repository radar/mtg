module Magic
  module Cards
    MakeAStand = Instant("Make a Stand") do
      cost generic: 2, white: 1
    end

    class MakeAStand < Instant
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          trigger_effect(:modify_power_toughness, target: creature, power: 1, toughness: 0)
          trigger_effect(:grant_keyword, target: creature, keyword: :indestructible)
        end
      end
    end
  end
end
