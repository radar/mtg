module Magic
  module Cards
    MalevolentChandelier = Creature("Malevolent Chandelier") do
      cost generic: 6
      artifact_creature_type "Construct"
      keywords :flying
      power 4
      toughness 4
    end

    class MalevolentChandelier < Creature
      # "{2}: Put target card from a graveyard on the bottom of its owner's library. Activate only as a sorcery."
      class BottomOfLibrary < Magic::ActivatedAbility
        costs "{2}"

        activate_only_as_sorcery

        def target_choices
          game.players.flat_map { _1.graveyard.cards }
        end

        def resolve!(target:)
          library = target.owner.library
          move_card target, to: library, placement: library.count
        end
      end

      def activated_abilities = [BottomOfLibrary]
    end
  end
end
