module Magic
  module Cards
    ThrashingBrontodon = Creature("Thrashing Brontodon") do
      cost generic: 1, green: 2
      creature_type "Dinosaur"
      power 3
      toughness 4
    end

    class ThrashingBrontodon < Creature
      class DestroyArtifactOrEnchantment < Magic::ActivatedAbility
        costs "{1}, Sacrifice {this}"

        def single_target?
          true
        end

        def target_choices
          game.battlefield.by_any_type("Artifact", "Enchantment")
        end

        def resolve!(target:)
          target.destroy!
        end
      end

      def activated_abilities = [DestroyArtifactOrEnchantment]
    end
  end
end
