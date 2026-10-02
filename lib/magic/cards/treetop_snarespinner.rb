module Magic
  module Cards
    TreetopSnarespinner = Creature("Treetop Snarespinner") do
      cost generic: 3, green: 1
      creature_type("Spider")
      keywords :reach, :deathtouch
      power 1
      toughness 4
    end

    class TreetopSnarespinner < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{G}"

        activate_only_as_sorcery

        def target_choices
          battlefield.controlled_by(controller).creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 1)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
