module Magic
  module Cards
    class BolassCitadel < Artifact
      card_name "Bolas's Citadel"
      type T::Super::Legendary, T::Artifact
      cost generic: 3, black: 3

      class SacrificeAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice ten nonland permanents"

        def resolve!
          game.opponents(controller).each { |opponent| opponent.lose_life(10) }
        end
      end

      # "Play with the top card of your library revealed. You may play lands and cast spells from the top of your
      # library. If you cast a spell this way, pay life equal to its mana value rather than pay its mana cost."
      class TopOfLibrary < StaticAbility
        def permits_casting_from_top?(card)
          card == controller.library.first
        end

        def pays_life_for?(card, player)
          player == controller && card == controller.library.first
        end

        # Read by arena's Table to show the top card to both players.
        def reveals_top_card?(player)
          player == controller
        end
      end

      def static_abilities = [TopOfLibrary]

      def activated_abilities = [SacrificeAbility]
    end
  end
end