module Magic
  module Cards
    RambunctiousMutt = Creature("Rambunctious Mutt") do
      cost generic: 3, green: 2
      type "Creature -- Dog"
      keywords :deathtouch
      power 2
      toughness 2
    end

    class RambunctiousMutt < Creature
      def entered_the_battlefield!
        add_effect(
          "DestroyTarget",
          choices: game.battlefield.cards.by_any_type("Artifact", "Enchantment").not_controlled_by(controller),
        )

        super
      end
    end
  end
end
