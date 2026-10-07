module Magic
  module Cards
    ExpeditionMap = Artifact("Expedition Map") do
      cost generic: 1
    end

    class ExpeditionMap < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def resolve!
          game.search_library(source, find: :lands, to: :hand, reveal: true)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
