module Magic
  module Cards
    RoamersRoutine = Sorcery("Roamer's Routine") do
      cost generic: 2, green: 1
      harmonize Costs::Mana.new(generic: 4, green: 1)
    end

    class RoamersRoutine < Sorcery
      def resolve!
        game.choices.add(Magic::Choice::SearchLibrary.new(actor: self, to_zone: :battlefield, enters_tapped: true, upto: 1, filter: Filter[:basic_lands]))
      end
    end
  end
end
