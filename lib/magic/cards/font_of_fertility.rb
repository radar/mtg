module Magic
  module Cards
    FontOfFertility = Enchantment("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end

    class FontOfFertility < Enchantment
      class Choice < Magic::Choice::SearchLibraryForBasicLand
        def initialize(source:)
          super(source: source, enters_tapped: true)
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{G}, Sacrifice {this}"

        def resolve!
          game.choices.add(Choice.new(source: source))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
