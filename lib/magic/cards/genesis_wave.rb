module Magic
  module Cards
    GenesisWave = Sorcery("Genesis Wave") do
      cost x: 1, green: 3
    end

    class GenesisWave < Sorcery
      def resolve!(value_for_x:)
        game.choices.add(Magic::Choice::PutOntoBattlefieldFromAmong.new(actor: self, cards: controller.library.cards.first(value_for_x).tap { controller.reveal(_1) }, filter: ->(card) { card.permanent? && card.mana_value <= value_for_x }))
      end
    end
  end
end
