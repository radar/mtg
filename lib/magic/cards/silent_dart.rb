module Magic
  module Cards
    SilentDart = Artifact("Silent Dart") do
      cost 1
    end

    class SilentDart < Artifact
      class ActivatedAbility < ActivatedAbility
        costs "{4}, Sacrifice {this}"

        def target_choices
          creatures
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
