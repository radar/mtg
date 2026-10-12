module Magic
  module Cards
    ShorelineLooter = Creature("Shoreline Looter") do
      cost generic: 1, blue: 1
      creature_type("Rat Rogue")
      power 1
      toughness 1
    end

    class ShorelineLooter < Creature
      def can_be_blocked?(_) = false

      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          trigger_effect(:draw_card)
          unless controller.graveyard.cards.count >= 7
            game.add_choice(Magic::Choice::Discard.new(player: controller))
          end
        end
      end

      def event_handlers = super.merge({ Events::CombatDamageDealt => CombatDamageTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
