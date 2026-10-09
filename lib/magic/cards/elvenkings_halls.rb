module Magic
  module Cards
    class ElvenkingsHalls < Land
      NAME = "Elvenking's Halls"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :green, :blue
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{G}{U}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures.by_any_type("Elf")
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
