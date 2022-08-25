module Magic
  module Cards
    AcidicSlime = Creature("Acidic Slime") do
      cost generic: 3, green: 2
      type "Creature -- Ooze"
      keywords :deathtouch
      power 2
      toughness 2
    end

    class AcidicSlime < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform

          effect = Effects::DestroyTarget.new(
            source: permanent,
            choices: game.battlefield.cards.by_any_type("Artifact", "Enchantment", "Land")
          )
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]

    end
  end
end
