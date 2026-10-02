module Magic
  module Cards
    ExpeditionMap = Artifact("Expedition Map") do
      cost generic: 1
    end

    class ExpeditionMap < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def resolve!
          game.choices.add(Magic::Choice::SearchLibrary.new(actor: source, to_zone: :hand, enters_tapped: false, upto: 1, filter: Filter[:lands], reveal: true))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
