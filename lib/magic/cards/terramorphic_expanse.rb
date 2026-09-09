module Magic
  module Cards
    TerramorphicExpanse = Card("Terramorphic Expanse") do
      type "Land"
    end

    class TerramorphicExpanse < Card
      class BasicLandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Sacrifice {this}"

        def resolve!
          game.add_choice(BasicLandChoice.new(actor: source))
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end