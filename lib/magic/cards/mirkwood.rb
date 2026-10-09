module Magic
  module Cards
    class Mirkwood < Land
      NAME = "Mirkwood"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :black, :green
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{B}{G}, {T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures.select { |c| %w[Bear Spider Wolf].any? { c.type?(_1) } }
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
