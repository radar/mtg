module Magic
  module Cards
    BonecacheOverseer = Creature("Bonecache Overseer") do
      cost black: 1
      creature_type("Squirrel Warlock")
      power 1
      toughness 1
    end

    class BonecacheOverseer < Creature
      # {T}, Pay 1 life: Draw a card. Activate only if three or more cards left your graveyard this turn or if
      # you've sacrificed a Food this turn.
      class DrawAbility < Magic::ActivatedAbility
        costs "{T}, Pay 1 life"

        def requirements_met?
          events = game.current_turn.events
          left = events.count { |event| event.is_a?(Events::CardLeavingZone) && event.from&.graveyard? && event.card.owner == controller }
          food = events.any? { |event| event.is_a?(Events::PermanentSacrificed) && event.permanent.controller == controller && event.permanent.type?("Food") }
          left >= 3 || food
        end

        def resolve!
          trigger_effect(:draw_cards, number_to_draw: 1)
        end
      end

      def activated_abilities = [DrawAbility]
    end
  end
end
