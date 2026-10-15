module Magic
  module Cards
    SneakySnacker = Creature("Sneaky Snacker") do
      cost blue: 1, black: 1
      creature_type "Faerie Rogue"
      power 2
      toughness 1
      keywords :flying
    end

    class SneakySnacker < Creature
      # "When you draw your third card in a turn, return this card from your graveyard to the battlefield tapped."
      class ThirdCardDrawTrigger < TriggeredAbility
        def self.works_from_graveyard? = true

        def should_perform?
          you? && actor.zone&.graveyard? &&
            game.current_turn.events.count { |e| e.is_a?(Events::CardDraw) && e.player == event.player } == 3
        end

        def call
          return unless actor.zone&.graveyard?

          Permanent.put_onto_battlefield(game: game, card: actor, from_zone: actor.zone, enters_tapped: true,
                                         controller: actor.owner)
        end
      end

      def event_handlers = { Events::CardDraw => ThirdCardDrawTrigger }
    end
  end
end
