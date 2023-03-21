module Magic
  module Cards
    BurnBright = Instant("Burn Bright") do
      cost generic: 2, red: 1

      def resolve!(controller)
        controller.creatures.each do |creature|
          game.add_effect(Effects::ApplyBuff.new(source: self, power: 2, targets: creature))
        end
         
      end
    end
  end
end
