module Magic
  module Cards
    PlazaOfHeroes = Card("Plaza of Heroes") do
      type T::Land
    end

    class PlazaOfHeroes < Card
      class ColorlessManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(colorless: 1)
        end
      end

      # Spend this mana only to cast a legendary spell.
      class LegendarySpellManaAbility < Magic::ManaAbility
        costs "{T}"
        choices :all
      end

      class LegendaryPermanentColorManaAbility < Magic::ManaAbility
        costs "{T}"

        def choices
          controller.permanents.select(&:legendary?).flat_map(&:colors).uniq
        end
      end

      class GrantHexproofIndestructible < Magic::ActivatedAbility
        costs "{3}, {T}, Exile {this}"

        def single_target? = true

        def target_choices
          game.battlefield.creatures.select(&:legendary?)
        end

        def resolve!(target:)
          target.grant_hexproof!
          target.grant_indestructible!
        end
      end

      def activated_abilities
        [
          ColorlessManaAbility,
          LegendarySpellManaAbility,
          LegendaryPermanentColorManaAbility,
          GrantHexproofIndestructible,
        ]
      end
    end
  end
end
