module Magic
  module Cards
    class BolassCitadel < Artifact
      card_name "Bolas's Citadel"
      type T::Super::Legendary, T::Artifact
      cost generic: 3, black: 3

      class SacrificeAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice a creature"

        def resolve!
          game.opponents(controller).each { |opponent| opponent.lose_life(10) }
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end