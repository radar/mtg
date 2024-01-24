module Magic
  module Cards
    Miscast = Instant("Miscast") do
      cost blue: 1, generic: 1
    end

    class Miscast < Instant
      class Choice < Magic::Choice
        attr_reader :source, :target
        def initialize(source:, target:)
          super(source:)
          @source = source
          @target = target
        end

        def inspect
          "#<Miscast::Counter target spell source:#{source}, target:#{target}>"
        end

        def costs
          @costs ||= [Costs::Mana.new(generic: 3)]
        end

        def pay(player, payment)
          cost = costs.first
          cost.pay!(player, payment)
        end

        def resolve!
          if costs.none?(&:paid?)
            effect = Effects::CounterSpell.new(source: source, targets: [target], choices: [target])
            game.add_effect(effect)
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
        game.choices.add(Choice.new(source: self, target:))
      end
    end
  end
end
