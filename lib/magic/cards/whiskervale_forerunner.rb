module Magic
  module Cards
    WhiskervaleForerunner = Creature("Whiskervale Forerunner") do
      cost generic: 3, white: 1
      creature_type("Mouse Bard")
      power 3
      toughness 4
    end

    class WhiskervaleForerunner < Creature
      # Valiant -- look at the top five cards of your library. You may reveal a creature card with mana
      # value 3 or less from among them. You may put it onto the battlefield if it's your turn. If you
      # don't put it onto the battlefield, put it into your hand. Put the rest on the bottom in a random order.
      class ValiantTrigger < TriggeredAbility::Valiant
        class LookChoice < Magic::Choice::LookAtTopCards
          def resolve!(target: nil)
            if target && controller == game.current_turn.active_player
              raise ArgumentError, "#{target.name} is not a valid choice" unless choices.include?(target)

              reveal_cards([target])
              Permanent.put_onto_battlefield(card: target, game: game, from_zone: target.zone, controller: controller)
              (looked_at - [target]).shuffle.each do |card|
                controller.library.remove(card)
                controller.library.push(card)
              end
            else
              super
            end
          end
        end

        def call
          game.choices.add(LookChoice.new(actor: actor, amount: 5, filter: ->(card) { card.creature? && card.mana_value <= 3 }))
        end
      end

      def event_handlers = super.merge(ValiantTrigger.handlers)
    end
  end
end
