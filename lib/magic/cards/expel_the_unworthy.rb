module Magic
  module Cards
    ExpelTheUnworthy = Sorcery("Expel The Unworthy") do
      cost generic: 1, white: 1
      kicker_cost generic: 2, white: 1
    end

    class ExpelTheUnworthy < Sorcery
      # "Choose target creature with mana value 3 or less. If this spell was kicked, instead choose target creature."
      def target_choices
        kicker_cost.paid? ? battlefield.creatures : battlefield.creatures.select { _1.cmc <= 3 }
      end

      # "Exile the chosen creature, then its controller gains life equal to its mana value."
      def resolve!(target:)
        controller = target.controller
        mana_value = target.cmc
        exile_target(target)
        controller.gain_life(mana_value)
      end
    end
  end
end
