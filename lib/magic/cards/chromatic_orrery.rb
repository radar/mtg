module Magic
  module Cards
    ChromaticOrrery = Artifact("Chromatic Orrery") do
      cost generic: 7
    end

    class ChromaticOrrery < Artifact
      class AnyColorForController < Abilities::Static::AnyColorForController
      end

      class AddColorlessMana < TapManaAbility
        def resolve!
          controller.add_mana(colorless: 5)
        end
      end

      class DrawCardsAbility < ActivatedAbility
        costs "{5}, {T}"

        def resolve!
          colors_count = game.battlefield
            .controlled_by(controller)
            .flat_map(&:colors)
            .uniq
            .count
          trigger_effect(:draw_cards, number_to_draw: colors_count)
        end
      end

      def activated_abilities = [AddColorlessMana, DrawCardsAbility]
      def static_abilities = [AnyColorForController]
    end
  end
end
