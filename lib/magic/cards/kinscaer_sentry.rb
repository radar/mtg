module Magic
  module Cards
    KinscaerSentry = Creature("Kinscaer Sentry") do
      cost generic: 1, white: 1
      creature_type("Kithkin Soldier")
      power 2
      toughness 2
      keywords :first_strike, :lifelink
    end

    class KinscaerSentry < Creature
      # Whenever this creature attacks, you may put a creature card with mana value X or less from
      # your hand onto the battlefield tapped and attacking, where X is the number of attacking
      # creatures you control.
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        class PutChoice < Magic::Choice::Targeted
          def choices
            x = game.current_turn.attacks.count { |attack| attack.attacker.controller == controller }
            hand.creatures.cmc_lte(x)
          end

          def choice_amount = 1

          def resolve!(target:)
            creature = Permanent.resolve(game: game, card: target, owner: controller, from_zone: target.zone, enters_tapped: true, cast: false)
            game.current_turn.declare_attacker(creature)
          end
        end

        class MayChoice < Magic::Choice::May
          def resolve!
            choice = PutChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def event_handlers = { Events::PreliminaryAttackersDeclared => AttackTrigger }
    end
  end
end
