module Magic
  module Cards
    Miscast = Instant("Miscast") do
      cost blue: 1, generic: 1
    end

    class Miscast < Instant
      class Choice < Magic::Choice
        attr_reader :actor, :target
        def initialize(actor:, target:)
          super(actor:)
          @actor = actor
          @target = target
        end

        def inspect
          "#<Miscast::Counter target spell actor:#{actor}, target:#{target}>"
        end

        def costs
          @costs ||= [Costs::Mana.new(generic: 3)]
        end

        def pay(player, payment)
          cost = costs.first
          cost.pay!(player:, payment:)
        end

        def resolve!
          if costs.none?(&:paid?)
            trigger_effect(:counter_spell, target: target)
          end
        end
      end

      def single_target?
        true
      end

      def target_choices
        game.stack
      end

      def resolve!(target:)
        game.choices.add(Choice.new(actor: self, target:))
      end
    end
  end
end
