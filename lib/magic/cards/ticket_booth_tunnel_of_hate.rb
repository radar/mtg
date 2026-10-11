module Magic
  module Cards
    class TicketBoothTunnelOfHate < Room
      class TicketBooth < Room::Door
        card_name "Ticket Booth"
        cost generic: 2, red: 1

        # "When you unlock this door, manifest dread."
        when_unlocked do
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      class TunnelOfHate < Room::Door
        card_name "Tunnel of Hate"
        cost generic: 4, red: 2

        class DoubleStrikeChoice < Magic::Choice::Targeted
          def initialize(actor:, attackers:)
            super(actor: actor)
            @attackers = attackers
          end

          def choices = @attackers

          def choice_amount = 1

          def resolve!(target:)
            target.grant_keyword(Cards::Keywords::DOUBLE_STRIKE, until_eot: true)
          end
        end

        # "Whenever you attack, target attacking creature gains double strike until end of turn."
        class AttackTrigger < TriggeredAbility
          def should_perform? = event.active_player == controller && event.attacks.any?

          def call
            game.add_choice(DoubleStrikeChoice.new(actor: actor, attackers: event.attacks.map(&:attacker)))
          end
        end

        def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
      end

      doors TicketBooth, TunnelOfHate
    end
  end
end
