module Magic
  module Cards
    WitchsClinic = Card("Witch's Clinic") { type "Land" }

    class WitchsClinic < Card
      class ManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # "{2}, {T}: Target commander gains lifelink until end of turn."
      class LifelinkAbility < Magic::ActivatedAbility
        costs "{2}, {T}"

        def target_choices
          commanders = game.players.filter_map(&:commander)
          game.battlefield.creatures.select { commanders.include?(_1.card) }
        end

        def resolve!(target:)
          trigger_effect(:grant_keyword, target: target, keyword: :lifelink)
        end
      end

      def activated_abilities = [ManaAbility, LifelinkAbility]
    end
  end
end
