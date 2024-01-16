module Magic
  module Cards
    BurnBright = Instant("Burn Bright") do
      cost generic: 2, red: 1
    end

    class BurnBright < Instant
      def resolve!
        controller.creatures.each do
          _1.modify_power!(2)
        end

        super
      end
    end
  end
end
