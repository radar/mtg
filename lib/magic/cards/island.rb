module Magic
  module Cards
    class Island < BasicLand
      NAME = "Island"
      TYPE_LINE = "Basic Land -- Island"

      class ManaAbility < Magic::ManaAbility
        def initialize(source:)
          @costs = [Costs::Tap.new(source)]

          super
        end

        def resolve!
          controller.add_mana(blue: 1)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
