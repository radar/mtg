module Magic
  module Cards
    BurnBright = Instant("Burn Bright") do
      cost generic: 2, red: 1
    end

    class BurnBright < Instant
      def resolve!(controller)
        controller.creatures.each do |creature|
           creature.modifiers << Magic::Permanents::Creature::Buff.new(power: 2, toughness: 0, until_eot: true)
        end

        super
      end
    end
  end
end
