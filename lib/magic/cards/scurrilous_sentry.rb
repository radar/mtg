module Magic
  module Cards
    # "Whenever this creature enters or attacks, it connives."
    ScurrilousSentry = Creature("Scurrilous Sentry") do
      cost generic: 3, black: 1
      creature_type "Human Knight Rogue"
      power 2
      toughness 3
      keywords :menace
      connive :enters, :attacks
    end
  end
end
