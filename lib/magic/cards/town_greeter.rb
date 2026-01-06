module Magic
  module Cards
    TownGreeter = Creature("Town Greeter") do
      cost "{1}{G}"
      creature_type "Human Citizen"
      power 1
      toughness 1

      enters_the_battlefield do
        cards = controller.mill(4)
        game.add_choice(TownGreeter::Choice.new(actor: self, milled_cards: cards))
      end
    end

    class TownGreeter
      class Choice < Magic::Choice::May
        def initialize(actor:, milled_cards:)
          super(actor: actor)
          @cards = milled_cards
        end

        def choices
          @cards.filter(Filter[:lands])
        end

        def resolve!(target:)
          trigger_effect(:move_card_zone, from: target.zone, target: target, to: controller.hand)
          trigger_effect(:gain_life, life: 2) if target.type?("Town")
        end
      end
    end
  end
end
