module Magic
  module Cards
    HedronArchive = Artifact("Hedron Archive") do
      cost generic: 4
    end

    class HedronArchive < Artifact
      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(colorless: 2)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{2}, {T}, Sacrifice {this}"

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
