module Magic
  module Cards
    MonumentalHenge = Card("Monumental Henge") do
      type "Land"
    end

    class MonumentalHenge < Card
      # Artifacts, legendaries, and Sagas are historic.
      def self.historic?(card) = card.artifact? || card.legendary? || card.type?("Saga")

      # "This land enters tapped unless you control a Plains."
      def enters_tapped?
        controller.lands.by_any_type("Plains").none?
      end

      class ManaAbility < Magic::TapManaAbility
        choices :white
      end

      # "You may reveal a historic card from among them and put it into your hand." Declining (`game.skip_choice!`)
      # puts all five on the bottom.
      class HistoricChoice < Magic::Choice::LookAtTopCards
        def decline!
          resolve!
        end
      end

      # "{2}{W}{W}, {T}: Look at the top five cards of your library. You may reveal a historic card from among them and
      # put it into your hand. Put the rest on the bottom of your library in a random order."
      class LookAbility < Magic::ActivatedAbility
        costs "{2}{W}{W}, {T}"

        def resolve!
          choice = HistoricChoice.new(actor: source, amount: 5, filter: ->(card) { MonumentalHenge.historic?(card) })
          # With nothing to reveal there is nothing to choose, but the cards still go to the bottom.
          choice.choices.empty? ? choice.resolve! : game.choices.add(choice)
        end
      end

      def activated_abilities = [ManaAbility, LookAbility]
    end
  end
end
