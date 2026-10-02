module Magic
  module Cards
    MysticArchaeologist = Creature("Mystic Archaeologist") do
      cost generic: 1, blue: 1
      creature_type("Human Wizard")
      power 2
      toughness 1
    end

    class MysticArchaeologist < Creature
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{3}{U}{U}"

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 2)
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
