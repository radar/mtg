module Magic
  module Cards
    DesolationOfSmaug = Sorcery("Desolation of Smaug") do
      cost generic: 2, red: 2
    end

    class DesolationOfSmaug < Sorcery
      # "Add four mana in any combination of colors. Spend this mana only to cast Dragon spells."
      # Answer with `mana:` as a { color => count } hash totalling four (default: all red).
      class ManaChoice < Magic::Choice
        COLORS = %i[white blue black red green].freeze

        def prompt = "Add four mana in any combination of colors (spend only on Dragon spells)"

        def resolve!(mana: { red: 4 })
          mana = mana.to_h
          raise ArgumentError, "choose four mana, got #{mana.inspect}" unless mana.values.sum == 4
          raise ArgumentError, "invalid colors #{mana.keys.inspect}" unless (mana.keys - COLORS).empty?

          controller.add_mana(mana, restriction: ManaRestriction::OfType.new(type: "Dragon"))
        end
      end

      # "Desolation of Smaug deals 3 damage to each non-Dragon creature."
      def resolve!
        game.battlefield.creatures.reject { _1.type?("Dragon") }.each do |creature|
          trigger_effect(:deal_damage, target: creature, damage: 3)
        end
        game.choices.add(ManaChoice.new(actor: self))
      end
    end
  end
end
