module Magic
  module Cards
    class CrypticCaves < Land
      NAME = "Cryptic Caves"

      class ManaAbility < Magic::TapManaAbility
        def resolve!
          source.controller.add_mana(colorless: 1)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{1}, {T}, Sacrifice {this}"

        def requirements_met?
          controller.lands.count >= 5
        end

        def resolve!
          trigger_effect(:draw_card)
        end
      end

      def activated_abilities = [ManaAbility, ActivatedAbility]
    end
  end
end
