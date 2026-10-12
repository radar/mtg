module Magic
  module Cards
    ThroughTheForestGate = Sorcery("Through the Forest Gate") do
      cost generic: 6, green: 2
    end

    class ThroughTheForestGate < Sorcery
      # "Look at the top twenty cards of your library, put any number of land cards from among them onto the
      # battlefield tapped, then shuffle."
      class LandsChoice < Magic::Choice::MoveToBattlefield
        def initialize(actor:)
          super
          @lands = CardList.new(actor.controller.library.first(20)).lands
        end

        def prompt = "Put any number of land cards from among the top twenty onto the battlefield tapped."

        def choices
          Magic::Targets::Choices.new(amount: 0..@lands.count, choices: @lands)
        end

        def resolve!(choices:)
          choices.each { |card| card.resolve!(enters_tapped: true) }
          controller.shuffle!
        end
      end

      def resolve!
        game.choices.add(LandsChoice.new(actor: self))
        trigger_effect(:gain_life, target: controller, life: 8)
        super
      end
    end
  end
end
