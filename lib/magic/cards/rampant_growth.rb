module Magic
  module Cards
    RampantGrowth = Sorcery("Rampant Growth") do
      cost generic: 1, green: 1
    end

    class RampantGrowth < Sorcery
      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

      def resolve!
        game.choices.add(Choice.new(actor: self))
        super
      end
    end
  end
end
