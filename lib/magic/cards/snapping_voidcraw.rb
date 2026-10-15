module Magic
  module Cards
    SnappingVoidcraw = Creature("Snapping Voidcraw") do
      cost generic: 1, green: 1, blue: 1
      power 1
      toughness 3
      creature_type "Eldrazi Turtle"
      keywords :devoid
    end

    class SnappingVoidcraw < Creature
      class ManaAbility < Magic::TapManaAbility
        def mana_produced = { colorless: 2 }
      end

      class DrawAbility < Magic::ActivatedAbility
        costs "{3}{C}, {T}"

        def resolve!
          draw_card
        end
      end

      def activated_abilities = [ManaAbility, DrawAbility]
    end
  end
end
