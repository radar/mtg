module Magic
  module Cards
    RunAfoul = Instant("Run Afoul") do
      cost generic: 1, green: 1
    end

    class RunAfoul < Instant
      class Choice < Magic::Choice::Targeted
        attr_reader :target

        def initialize(actor:, target:)
          super(actor: actor)
          @target = target
        end

        def choices
          target.creatures.select(&:flying?)
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          actor.trigger_effect(:sacrifice, target: target)
        end
      end

      def single_target?
        true
      end

      def target_choices
        game.opponents(controller)
      end

      def resolve!(target:)
        return if target.creatures.none?(&:flying?)

        game.add_choice(Choice.new(actor: self, target: target))
      end
    end
  end
end
