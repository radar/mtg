module Magic
  module Cards
    AgentOfKotis = Creature("Agent of Kotis") do
      cost generic: 1, blue: 1
      creature_type("Human Rogue")
      power 2
      toughness 1
    end

    class AgentOfKotis < Creature
      class GraveyardAbility < Magic::ActivatedAbility
        costs "{3}{U}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def target_choices
          battlefield.creatures
        end

        def resolve!(target:)
          trigger_effect(:add_counter, counter_type: "+1/+1", target: target, amount: 2)
        end
      end

      def graveyard_abilities = [GraveyardAbility.new(source: self)]
    end
  end
end
