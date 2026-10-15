module Magic
  module Cards
    DesertedTemple = Card("Deserted Temple") do
      type T::Land
    end

    class DesertedTemple < Card
      # "{T}: Add {C}."
      class ManaAbility < Magic::TapManaAbility
        choices :colorless

        def mana_produced = { colorless: 1 }
      end

      # "{1}, {T}: Untap target land."
      class UntapLand < Magic::ActivatedAbility
        costs "{1}, {T}"

        def target_choices
          game.battlefield.lands
        end

        def resolve!(target:)
          target.untap!
        end
      end

      def activated_abilities = [ManaAbility, UntapLand]
    end
  end
end
