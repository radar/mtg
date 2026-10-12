module Magic
  module Cards
    MakeAStand = Instant("Make a Stand") do
      cost generic: 2, white: 1
    end

    class MakeAStand < Instant
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 1, 0)
          trigger_effect(:grant_keyword, target: creature, keyword: :indestructible)
        end
      end
    end
  end
end
