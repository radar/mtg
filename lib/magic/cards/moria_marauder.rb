module Magic
  module Cards
    MoriaMarauder = Creature("Moria Marauder") do
      cost red: 2
      creature_type "Goblin Warrior"
      power 1
      toughness 1
      keywords :double_strike
    end

    class MoriaMarauder < Creature
      # "Whenever a Goblin or Orc you control deals combat damage to a player, exile the top card of your library. You may
      # play that card this turn." Each creature (and each strike of a double striker) triggers separately.
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          source = event.source
          source.is_a?(Magic::Permanent) && source.controller == controller && event.target.player? &&
            event.damage.positive? && (source.type?("Goblin") || source.type?("Orc"))
        end

        def call
          top = controller.library.first
          return unless top

          top.exile!
          game.play_permissions.grant_until_end_of_turn(card: top, player: controller)
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
