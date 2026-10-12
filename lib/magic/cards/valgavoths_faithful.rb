module Magic
  module Cards
    ValgavothsFaithful = Creature("Valgavoth's Faithful") do
      cost black: 1
      creature_type("Human Cleric")
      power 1
      toughness 1
    end

    class ValgavothsFaithful < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}{B}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          controller.graveyard.cards.select { _1.type?("Creature") }
        end

        def resolve!(target:)
          trigger_effect(:return_target_from_graveyard_to_battlefield, target: target, controller: target.owner)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
