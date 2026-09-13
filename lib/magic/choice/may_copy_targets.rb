module Magic
  class Choice
    # Wraps CopyTargets in the "may" pattern: declining keeps the copy/copies
    # resolving against the original targets instead of skipping them outright.
    class MayCopyTargets < Magic::Choice::May
      def initialize(actor:, receiver:, original_targets:, copies: 1)
        super(actor: actor)
        @receiver = receiver
        @original_targets = original_targets
        @copies = copies
      end

      def resolve!
        game.choices.add(Magic::Choice::CopyTargets.new(actor: actor, receiver: @receiver, copies: @copies))
      end

      def decline!
        @copies.times { Magic::CopyEffect.resolve!(@receiver, targets: @original_targets) }
      end
    end
  end
end
