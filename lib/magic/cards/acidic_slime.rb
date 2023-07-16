module Magic
  module Cards
    AcidicSlime = Creature("Acidic Slime") do
      cost generic: 3, green: 2
      creature_type("Ooze")
      keywords :deathtouch
      power 2
      toughness 2
    end

    class AcidicSlime < Creature
      def target_choices(_)
        game.battlefield.cards.by_any_type("Artifact", "Enchantment", "Land")
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform

          effect = Effects::DestroyTarget.new(
            source: permanent,
          )
          game.add_effect(effect)
        end
      end

      def etb_triggers = [ETB]

    end
  end
end
