module Magic
  module Cards
    class Plains < BasicLand
      NAME = "Plains"
      TYPE_LINE = "Basic Land -- Plains"

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          controller.add_mana(white: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
