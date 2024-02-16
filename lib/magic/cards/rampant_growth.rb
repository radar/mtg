module Magic
  module Cards
    RampantGrowth = Sorcery("Rampant Growth") do
      cost generic: 1, green: 1
    end

    class RampantGrowth < Sorcery
      class Choice < Magic::Choice::SearchLibraryForBasicLand
        def initialize(actor:)
          super(actor: actor, enters_tapped: true)
        end
      end

      def resolve!
        game.choices.add(Choice.new(actor: self))
        super
      end
    end
  end
end
