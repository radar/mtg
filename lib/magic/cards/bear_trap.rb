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
          deal_damage(3, to: target)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
