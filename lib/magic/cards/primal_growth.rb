module Magic
  module Cards
    PrimalGrowth = Sorcery("Primal Growth") do
      cost generic: 2, green: 1
    end

    class PrimalGrowth < Sorcery
      def kicker_cost
        @sacrifice_kicker_cost ||= Costs::SacrificeKicker.new
      end

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, upto: actor.kicker_cost.paid? ? 2 : 1, filter: Filter[:basic_lands])
        end

        def resolve!(targets:)
          targets.each { |target| target.resolve! }
          controller.shuffle!
        end
      end

      def resolve!
        game.choices.add(PrimalGrowth::Choice.new(actor: self))
      end
    end
  end
end
