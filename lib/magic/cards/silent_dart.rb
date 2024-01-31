module Magic
  module Cards
    SilentDart = Artifact("Silent Dart") do
      cost 1
    end

    class SilentDart < Artifact
      class ActivatedAbility < ActivatedAbility
        def costs
          [
            Costs::Mana.new(generic: 4),
            Costs::Sacrifice.new(source)
          ]
        end

        def target_choices
          game.battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, damage: 3, target: target)
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end
    end
  end
end
