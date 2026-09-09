module Magic
  module Cards
    TheGitrogMonster = Creature("The Gitrog Monster") do
      legendary_creature_type "Frog Horror"
      cost generic: 3, black: 1, green: 1
      power 6
      toughness 6
      keywords :deathtouch
    end
  end
end