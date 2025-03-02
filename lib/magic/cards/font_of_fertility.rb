module Magic
  module Cards
    FontOfFertility = Enchantment("Font of Fertility") do
      type "Enchantment"
      cost green: 1
    end

    class FontOfFertility < Enchantment
      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(
            actor: actor,
            to_zone: :battlefield,
            enters_tapped: true,
            filter: Filter[:basic_lands]
          )
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{G}, Sacrifice {this}"

        def resolve!
          game.choices.add(Choice.new(actor: source))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
