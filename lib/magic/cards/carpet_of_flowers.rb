module Magic
  module Cards
    CarpetOfFlowers = Enchantment("Carpet of Flowers") do
      cost green: 1
    end

    class CarpetOfFlowers < Enchantment
      class MainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller &&
            !game.current_turn.events.any? { |event| event.is_a?(Events::ManaAddedByCarpet) }
        end

        def call
          game.add_choice(ColorChoice.new(actor: actor)) if game.opponents(controller).any? { |opponent| opponent.lands.by_any_type("Island").any? }
        end
      end

      class ColorChoice < Magic::Choice::Color
        def resolve!(color:)
          islands = game.opponents(controller).sum { |opponent| opponent.lands.by_any_type("Island").count }
          controller.add_mana(color => islands)
          game.current_turn.events << Events::ManaAddedByCarpet.new
        end
      end

      def event_handlers
        { Events::FirstMainPhase => MainPhaseTrigger }
      end
    end
  end
end