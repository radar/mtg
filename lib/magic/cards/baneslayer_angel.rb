module Magic
  module Cards
    BaneslayerAngel = Creature("Baneslayer Angel") do
      creature_type("Angel")
      cost generic: 3, white: 2
      power 5
      toughness 5
      keywords :flying, :first_strike, :lifelink
      protections [Protection.new(condition: -> (card) { card.any_type?("Demon", "Dragon") })]
    end
  end
end
