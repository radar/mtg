module Magic
  module Cards
    class Forest < BasicLand
      NAME = "Forest"
      TYPE_LINE = "Basic Land -- Forest"

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          controller.add_mana(green: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
