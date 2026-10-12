module Magic
  module Cards
    class LakeTown < Land
      NAME = "Lake-town"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :white, :blue
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{W}{U}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures.by_any_type("Human")
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
