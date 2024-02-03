module Magic
  module Cards
    TormodsCrypt = Artifact("Tormod's Crypt") do
      cost generic: 0
    end

    class TormodsCrypt < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def target_choices
          game.players
        end

        def resolve!(target:)
          target.graveyard.each do |card|
            trigger_effect(:exile, target: card)
          end
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
