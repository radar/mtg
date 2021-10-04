module Magic
  module Cards
    BaneslayerAngel = Creature("Baneslayer Angel") do
      type "Creature -- Angel"
      cost generic: 3, white: 2
      power 5
      toughness 5
      keywords :flying, :first_strike, :lifelink
    end

    class BaneslayerAngel < Creature
      def protected_from?(card)
        card.type?("Demon") || card.type?("Dragon")
      end
    end
  end
end
