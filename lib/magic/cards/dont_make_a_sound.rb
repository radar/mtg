module Magic
  module Cards
    DontMakeASound = Instant("Don't Make A Sound") do
      cost blue: 1, generic: 1
    end

    class DontMakeASound < Instant
      # "Counter target spell unless its controller pays {2}. If they do, surveil 2."
      class Choice < Magic::Choice
        attr_reader :target

        def initialize(actor:, target:)
          super(actor:)
          @target = target
        end

        def inspect
          "#<Don't Make A Sound::Counter target spell source:#{source}, target:#{target}>"
        end

        def costs
          @costs ||= [Costs::Mana.new(generic: 2)]
        end

        def pay(player, payment)
          costs.first.pay!(player:, payment:)
        end

        def resolve!
          if costs.none?(&:paid?)
            trigger_effect(:counter_spell, target: target)
          else
            game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
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
