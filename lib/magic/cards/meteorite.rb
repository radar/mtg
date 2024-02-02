module Magic
  module Cards
    Meteorite = Artifact("Meteorite") do
      cost generic: 5

      enters_the_battlefield do
        game.choices.add(Meteorite::Choice.new(source: source))
      end
    end

    class Meteorite < Artifact
      class Choice < Magic::Choice::Targeted
        def choices
          game.any_target
        end

        def resolve!(target:)
          source.trigger_effect(:deal_damage, target:, damage: 2)
        end
      end

      class ManaAbility < TapManaAbility
        choices :all
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
