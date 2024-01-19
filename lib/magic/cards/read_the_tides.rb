module Magic
  module Cards
    ReadTheTides = Sorcery("Read the Tides") do
      cost generic: 5, blue: 1

      class DrawThreeCards < Magic::Effect
        def resolve
          game.add_effect(Effects::DrawCards.new(source: source, player: controller, number_to_draw: 3))
        end
      end

      class ReturnUpToTwoTargetCreatures < Magic::Effect
        def choices
          game.battlefield.creatures
        end

        def targeting(*targets)
          @targets = targets
          self
        end

        def resolve
          targets.each(&:return_to_hand)
        end
      end

      modes DrawThreeCards, ReturnUpToTwoTargetCreatures
    end
  end
end
