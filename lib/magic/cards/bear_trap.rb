module Magic
  module Cards
    BearTrap = Artifact("Bear Trap") do
      cost generic: 1
      keywords :flash
    end

    class BearTrap < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}, {T}, Sacrifice {this}"

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:deal_damage, target: target, damage: 3)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
