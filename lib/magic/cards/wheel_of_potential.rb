module Magic
  module Cards
    class WheelOfPotential < Sorcery
      card_name "Wheel of Potential"
      cost generic: 2, red: 1

      # Each player may exile their hand and draw a number of cards equal to the {E} paid. Declining does nothing.
      class ExileHandChoice < Magic::Choice::May
        def initialize(actor:, player:, amount:)
          @player = player
          @amount = amount
          super(actor: actor)
        end

        def chooser = @player

        def prompt = "Exile your hand and draw #{@amount} cards?"

        def resolve!
          exiled = @player.hand.cards.to_a.dup
          exiled.each { exile_target(_1) }
          draw_cards(@amount, player: @player)
          # If seven or more {E} was paid this way, you may play cards you own exiled this way until the end of your
          # next turn.
          return unless @player == controller && @amount >= 7

          exiled.select { _1.owner == controller && _1.zone&.exile? }.each do |card|
            game.play_permissions.grant_until_end_of_next_turn(card:, player: controller)
          end
        end
      end

      # You may pay any amount of {E}; declining pays 0.
      class PayChoice < Magic::Choice::PayAnyEnergy
        def paid(amount)
          # Choices are answered newest first, so add them in reverse: you decide first.
          [controller, *game.opponents(controller)].reverse.each do |player|
            game.add_choice(ExileHandChoice.new(actor: actor, player:, amount:))
          end
        end
      end

      # You get {E}{E}{E}, then you may pay any amount of {E}.
      def resolve!
        gain_energy 3
        game.add_choice(PayChoice.new(actor: self))
      end
    end
  end
end
