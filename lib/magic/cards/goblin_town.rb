module Magic
  module Cards
    class GoblinTown < Land
      NAME = "Goblin-town"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{B}{R}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures.select { _1.type?("Goblin") || _1.type?("Orc") }
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
