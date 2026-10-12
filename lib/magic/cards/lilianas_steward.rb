module Magic
  module Cards
    LilianasSteward = Creature("Liliana's Steward") do
      cost black: 1
      creature_type("Zombie")
      power 1
      toughness 2
    end

    class LilianasSteward < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        activate_only_as_sorcery

        def target_choices
          game.opponents(controller)
        end

        def resolve!(target:)
          game.add_choice(Magic::Choice::Discard.new(player: target))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
