module Magic
  module Cards
    MakeAStand = Instant("Make a Stand") do
      cost generic: 2, white: 1
    end

    class MakeAStand < Instant
      def resolve!
        battlefield.controlled_by(controller).creatures.each do |creature|
          pump(creature, 1, 0)
          give_keyword(creature, :indestructible)
        end
      end
    end
  end
end
