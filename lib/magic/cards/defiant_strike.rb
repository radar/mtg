module Magic
  module Cards
    DefiantStrike = Instant("Defiant Strike") do
      cost white: 1
    end

    class DefiantStrike < Instant
      def resolve!
        add_effect("ApplyBuff", power: 1, choices: battlefield.creatures)
        add_effect("DrawCards", player: controller)
        super
      end
    end
  end
end
