module Magic
  module Cards
    ReadTheTides = Sorcery("Read the Tides") do
      cost generic: 5, blue: 1

      class DrawThreeCards < Mode
        def resolve!
          game.add_effect(Effects::DrawCards.new(source: source, player: source.controller, number_to_draw: 3))
        end
      end

      class ReturnUpToTwoTargetCreatures < Mode
        def target_choices
          game.battlefield.creatures
        end

        def resolve!(targets:)
          targets.each(&:return_to_hand)
        end
      end

      modes DrawThreeCards, ReturnUpToTwoTargetCreatures
    end
  end
end
