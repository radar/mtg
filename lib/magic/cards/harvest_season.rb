module Magic
  module Cards
    HarvestSeason = Sorcery("Harvest Season") do
      cost generic: 2, green: 1
    end

    class HarvestSeason < Sorcery
      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands],
                upto: actor.controller.creatures.tapped.count)
        end
      end

      def resolve!
        game.choices.add(Choice.new(actor: self))
        super
      end
    end
  end
end
