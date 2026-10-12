module Magic
  module Cards
    SilentDart = Artifact("Silent Dart") do
      cost generic: 1
    end

    class SilentDart < Artifact
      class ActivatedAbility < ActivatedAbility
        costs "{4}, Sacrifice {this}"

        def target_choices
          creatures
        end

        def resolve!(target:)
          deal_damage(3, to: target)
        end
      end

      def activated_abilities
        [ActivatedAbility]
      end
    end
  end
end
