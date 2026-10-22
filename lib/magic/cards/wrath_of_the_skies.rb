module Magic
  module Cards
    WrathOfTheSkies = Sorcery("Wrath Of The Skies") do
      cost x: 1, white: 2
    end

    class WrathOfTheSkies < Sorcery
      # You may pay any amount of {E}. Destroy each artifact, creature, and enchantment with mana value less than or
      # equal to the amount of {E} paid this way. Declining pays 0, which still destroys mana value 0 permanents.
      class PayChoice < Magic::Choice::PayAnyEnergy
        def paid(amount)
          game.battlefield.permanents
            .select { _1.artifact? || _1.creature? || _1.enchantment? || _1.card.is_a?(Cards::Aura) }
            .select { _1.mana_value <= amount }
            .each { destroy(_1) }
        end
      end

      # You get X {E}, then you may pay any amount of {E}.
      def resolve!(value_for_x: 0)
        gain_energy value_for_x
        game.add_choice(PayChoice.new(actor: self))
      end
    end
  end
end
