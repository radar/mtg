module Magic
  module Cards
    ConduitOfWorlds = Artifact("Conduit of Worlds") do
      cost generic: 2, green: 2
    end

    class ConduitOfWorlds < Artifact
      def additional_lands_per_turn = 1

      class CastFromGraveyardAbility < Magic::ActivatedAbility
        costs "{T}"

        def target_choices
          controller.graveyard.nonland
        end

        def requirements_met?
          game.can_cast_sorcery?(controller) && game.current_turn.spells_cast.empty?
        end

        def resolve!(target:)
          target.resolve!
        end
      end

      def activated_abilities = [CastFromGraveyardAbility]
    end
  end
end
