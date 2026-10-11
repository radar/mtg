module Magic
  module Cards
    StalkedResearcher = Creature("Stalked Researcher") do
      cost generic: 1, blue: 1
      creature_type "Human Wizard"
      keywords :defender
      power 3
      toughness 3
    end

    class StalkedResearcher < Creature
      # The number of the turn this creature may attack as though it didn't have defender.
      attr_accessor :may_attack_turn

      # "Eerie -- Whenever an enchantment you control enters and whenever you fully unlock a Room, this creature can
      # attack this turn as though it didn't have defender."
      class EerieTrigger < TriggeredAbility::Eerie
        def call
          actor.card.may_attack_turn = game.current_turn.number
        end
      end

      def can_attack?
        super || may_attack_turn == game.current_turn.number
      end

      def event_handlers = EerieTrigger.handlers
    end
  end
end
