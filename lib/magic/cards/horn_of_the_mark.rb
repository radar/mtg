module Magic
  module Cards
    HornOfTheMark = Artifact("Horn of the Mark") do
      legendary_artifact
      cost generic: 2
    end

    class HornOfTheMark < Artifact
      # "You may reveal a creature card from among them and put it into your hand." Declining puts all five on the
      # bottom in a random order.
      class LookChoice < Magic::Choice::LookAtTopCards
        def decline! = resolve!(target: nil)
      end

      # "Whenever two or more creatures you control attack a player, look at the top five cards of your library..."
      # One trigger per attack declaration, however many creatures attack.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller &&
            event.attacks
                 .select { _1.target&.player? && _1.attacker.controller == controller }
                 .group_by(&:target)
                 .values.any? { _1.size >= 2 }
        end

        def call
          game.add_choice(
            LookChoice.new(actor: actor, amount: 5, filter: ->(card) { card.creature? })
          )
        end
      end

      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
