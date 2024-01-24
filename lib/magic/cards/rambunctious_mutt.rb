module Magic
  module Cards
    RambunctiousMutt = Creature("Rambunctious Mutt") do
      cost generic: 3, green: 2
      creature_type("Dog")
      keywords :deathtouch
      power 2
      toughness 2

      enters_the_battlefield do
        game.choices.add(RambunctiousMutt::Choice.new(source: permanent))
      end
    end

    class RambunctiousMutt < Creature
      class Choice < Choice::DestroyTarget
        def choices
          game.battlefield.cards.by_any_type("Artifact", "Enchantment").not_controlled_by(source.controller)
        end
      end
    end
  end
end
