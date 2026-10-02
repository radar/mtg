module Magic
  module Cards
    GoblinFirebomb = Artifact("Goblin Firebomb") do
      cost generic: 1
      keywords :flash
    end

    class GoblinFirebomb < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{7}, {T}, Sacrifice {this}"

        def target_choices
          battlefield.permanents
        end

        def resolve!(target:)
          trigger_effect(:destroy_target, target: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
