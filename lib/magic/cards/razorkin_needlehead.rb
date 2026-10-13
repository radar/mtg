module Magic
  module Cards
    RazorkinNeedlehead = Creature("Razorkin Needlehead") do
      cost red: 2
      creature_type "Human Assassin"
      power 2
      toughness 2
    end

    class RazorkinNeedlehead < Creature
      # "This creature has first strike during your turn."
      class FirstStrikeOnYourTurn < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FIRST_STRIKE

        def applies_to?(permanent)
          permanent == source && game.current_turn.active_player == source.controller
        end

        def applicable_targets
          [source]
        end
      end

      # "Whenever an opponent draws a card, this creature deals 1 damage to them."
      class DrawTrigger < TriggeredAbility
        def should_perform?
          event.player != controller
        end

        def call
          deal_damage 1, to: event.player
        end
      end

      def static_abilities = [FirstStrikeOnYourTurn]

      def event_handlers = { Events::CardDraw => DrawTrigger }
    end
  end
end
