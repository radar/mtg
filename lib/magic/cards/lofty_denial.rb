module Magic
  module Cards
    LoftyDenial = Instant("Lofty Denial") do
      cost blue: 1, generic: 1
    end

    class LoftyDenial < Instant
      class Choice < Magic::Choice::Effect
        attr_reader :target
        def initialize(source:, target:)
          super(source:)
          @target = target
        end

        def inspect
          "#<Lofty Denial::Counter target spell source:#{source}, target:#{target}>"
        end

        def costs
          has_flying = source.controller.creatures.any?(&:flying?)
          @costs ||= [Costs::Mana.new(generic: has_flying ? 4 : 1)]
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
        super
      end
    end
  end
end
