module Magic
  module Cards
    MalevolentRumble = Sorcery("Malevolent Rumble") do
      cost generic: 1, green: 1
    end

    class MalevolentRumble < Sorcery
      # "You may put a permanent card from among them into your hand. Put the rest into your graveyard."
      class PickPermanent < Magic::Choice::ReturnFromAmong
        def resolve!(target: nil)
          super
          cards.each { _1.move_to_graveyard! unless _1.zone.hand? }
        end

        def decline!
          cards.each(&:move_to_graveyard!)
        end
      end

      # "Reveal the top four cards of your library..." then a 0/1 Eldrazi Spawn token.
      def resolve!
        revealed = controller.library.cards.first(4)
        reveal_cards revealed
        game.add_choice(PickPermanent.new(actor: self, cards: revealed, filter: ->(card) { card.permanent? }))
        create_eldrazi_spawn
      end
    end
  end
end
