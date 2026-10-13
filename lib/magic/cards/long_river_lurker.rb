module Magic
  module Cards
    LongRiverLurker = Creature("Long River Lurker") do
      cost generic: 2, blue: 1
      creature_type("Frog Scout")
      power 2
      toughness 3
      ward generic: 1
    end

    class LongRiverLurker < Creature
      # Other Frogs you control have ward {1}.
      class FrogWard < TriggeredAbility::GrantedWard
        def warded?(permanent) = permanent != actor && permanent.type?("Frog")
      end

      # When this creature enters, target creature you control can't be blocked this turn. Whenever that creature
      # deals combat damage this turn, you may exile it. If you do, return it to the battlefield under its
      # owner's control.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class BlinkOnDamage < TriggeredAbility
          class MayBlink < Magic::Choice::May
            def resolve!
              card = actor.card
              exile_target(actor)
              card.resolve!(controller: card.owner) if card.zone&.exile?
            end
          end

          def should_perform? = event.source == actor

          def call
            game.choices.add(MayBlink.new(actor: actor))
          end
        end

        class UnblockableChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures

          def choice_amount = 1

          def resolve!(target:)
            target.cant_be_blocked_this_turn!
            target.register_turn_trigger(Events::CombatDamageDealt, BlinkOnDamage)
          end
        end

        def call
          game.add_choice(UnblockableChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        handlers = super
        merged = FrogWard.handlers.merge(handlers) { |_event, ours, theirs| [*theirs, ours] }
        merged
      end
    end
  end
end
