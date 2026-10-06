module Magic
  module Cards
    MysticRemora = Enchantment("Mystic Remora") do
      cost blue: 1
    end

    class MysticRemora < Enchantment
      # Cumulative upkeep {1}: "At the beginning of your upkeep, put an age counter on this permanent, then sacrifice
      # it unless you pay its upkeep cost for each age counter on it." Declining (or being unable to pay) sacrifices it.
      class UpkeepChoice < Magic::Choice::May
        # What a UI pays on the player's behalf: {1} for each age counter.
        def payment_cost(_x = nil) = { generic: actor.counters.count { _1.is_a?(Counters["age"]) } }

        def resolve!(payment: {})
          controller.pay_mana(payment)
        end

        def decline!
          actor.sacrifice!
        end
      end

      class UpkeepTrigger < TriggeredAbility::BeginningOfYourUpkeep
        def call
          trigger_effect(:add_counter, target: actor, counter_type: "age", amount: 1)
          game.choices.add(UpkeepChoice.new(actor: actor))
        end
      end

      # "Whenever an opponent casts a noncreature spell, you may draw a card unless that player pays {4}." The caster is
      # asked first; drawing is never worse for the Remora's controller, so a refusal always draws.
      class PayOrDrawChoice < Magic::Choice::May
        attr_reader :player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        # The caster decides, and pays, not the Remora's controller.
        def controller = player

        def payment_cost(_x = nil) = { generic: 4 }

        def resolve!(payment: {})
          player.pay_mana(payment)
        end

        def decline!
          actor.controller.draw!
        end
      end

      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          event.player != controller && !spell.type?("Creature")
        end

        def call
          game.choices.add(PayOrDrawChoice.new(actor: actor, player: event.player))
        end
      end

      def event_handlers
        {
          Events::BeginningOfUpkeep => UpkeepTrigger,
          Events::SpellCast => SpellCastTrigger,
        }
      end
    end
  end
end
