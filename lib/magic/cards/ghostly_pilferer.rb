# Ghostly Pilferer {1}{U}
# Creature — Spirit Rogue
# Whenever Ghostly Pilferer becomes untapped, you may pay {2}. If you do, draw a card.
# Whenever an opponent casts a spell from anywhere other than their hand, draw a card.
# Discard a card: Ghostly Pilferer can't be blocked this turn.
# 2/1

module Magic
  module Cards
    GhostlyPilferer = Creature("Ghostly Pilferer") do
      creature_type "Spirit Rogue"
      power 2
      toughness 1
    end

    class GhostlyPilferer < Creature
      class Choice < Magic::Choice::May
        def costs
          @costs ||= [Costs::Mana.new(generic: 2)]
        end

        def pay(player:, payment:)
          cost = costs.first
          cost.pay!(player:, payment:)
        end

        def resolve!
          if costs.all?(&:paid?)
            controller.draw!
          end
        end
      end

      class PermanentUntapped < TriggeredAbility
        def should_perform?
          this?
        end

        def resolve
          Choice.new(actor: actor)
        end
      end

      def event_handlers
        { Events::PermanentUntapped => PermanentUntapped }
      end
    end
  end
end
