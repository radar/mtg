module Magic
  module Cards
    class BotanicalPlaza < Land
      NAME = "Botanical Plaza"

      enters_tapped

      class ManaAbility < Magic::TapManaAbility
        choices :green, :white
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}{G}{W}, {T}, Sacrifice {this}"

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
