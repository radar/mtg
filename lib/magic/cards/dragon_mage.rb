module Magic
  module Cards
    DragonMage = Creature("Dragon Mage") do
      cost generic: 5, red: 2
      creature_type("Dragon Wizard")
      keywords :flying
      power 5
      toughness 5
    end

    class DragonMage < Creature
      class CombatDamageTrigger < TriggeredAbility
        def should_perform?
          event.source == actor && event.target.is_a?(Magic::Player)
        end

        def call
          game.players.each { |player| [*player.hand.cards].each(&:discard!) }
          game.players.each { |player| draw_cards(7, player: player) }
        end
      end

      def event_handlers = { Events::CombatDamageDealt => CombatDamageTrigger }
    end
  end
end
