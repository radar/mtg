module Magic
  module Cards
    class IronHills < Land
      NAME = "Iron Hills"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :red, :white
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{R}{W}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures.by_any_type("Dwarf")
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
