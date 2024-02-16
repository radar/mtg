module Magic
  module Cards
    AcidicSlime = Creature("Acidic Slime") do
      cost generic: 3, green: 2
      creature_type("Ooze")
      keywords :deathtouch
      power 2
      toughness 2

      enters_the_battlefield do
        game.choices.add(AcidicSlime::Choice.new(actor: actor))
      end
    end

    class AcidicSlime < Creature
      class Choice < Choice::DestroyTarget
        def choices = game.battlefield.cards.by_any_type("Artifact", "Enchantment", "Land")
      end
    end
  end
end
