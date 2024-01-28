module Magic
  module Cards
    TormodsCrypt = Artifact("Tormod's Crypt") do
      cost generic: 0
    end

    class TormodsCrypt < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        def costs
          [
            Costs::Tap.new(source),
            Costs::Sacrifice.new(source: source),
          ]
        end

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
