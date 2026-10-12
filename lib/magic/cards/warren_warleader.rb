module Magic
  module Cards
    WarrenWarleader = Creature("Warren Warleader") do
      cost generic: 2, white: 2
      creature_type("Rabbit Knight")
      power 4
      toughness 4
      offspring generic: 2
    end

    class WarrenWarleader < Creature
      # Whenever you attack, choose one -- create a 1/1 white Rabbit token that's tapped and attacking; or
      # attacking creatures you control get +1/+1 until end of turn.
      class AttackTrigger < TriggeredAbility::YouAttack
        class ModeChoice < Magic::Choice
          MODES = %i[token pump].freeze

          def initialize(actor:, attackers:, target:)
            @attackers = attackers
            @target = target
            super(actor: actor)
          end

          def choices = MODES

          def resolve!(mode:)
            case mode
            when :token
              trigger_effect(:create_token, token_class: Tokens::Rabbit, enters_tapped: true, attacking: true, attack_target: @target)
            when :pump
              @attackers.each { pump(_1, 1, 1) }
            else
              raise ArgumentError, "choose :token or :pump"
            end
          end
        end

        def call
          target = event.attacks.first.target
          game.choices.add(ModeChoice.new(actor: actor, attackers: attackers, target: target))
        end
      end

      def event_handlers = super.merge(AttackTrigger.handlers)
    end
  end
end
