module Magic
  class TriggeredAbility
    # "Whenever you attack" (one or more creatures you control attack): fires once per attack declaration,
    # on your turn. Wire it with `SubclassName.handlers` from `event_handlers`; `attackers` are the
    # attacking creatures.
    class YouAttack < TriggeredAbility
      def self.handlers
        { Events::FinalAttackersDeclared => self }
      end

      def attackers = event.attacks.map(&:attacker)

      def should_perform?
        event.active_player == controller && event.attacks.any?
      end
    end
  end
end
