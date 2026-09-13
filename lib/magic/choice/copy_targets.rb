module Magic
  class Choice
    # "You may choose new targets for the copy/copies." `receiver` is the
    # card or ability being copied (whatever CopyEffect.resolve! expects);
    # `copies` is how many times to resolve the copy with the chosen target.
    class CopyTargets < Magic::Choice::Targeted
      def initialize(actor:, receiver:, copies: 1)
        super(actor: actor)
        @receiver = receiver
        @copies = copies
      end

      def choice_amount
        1
      end

      def choices
        method = @receiver.method(:target_choices)
        method.arity == 1 ? @receiver.target_choices(controller) : @receiver.target_choices
      end

      def resolve!(target:)
        @copies.times { Magic::CopyEffect.resolve!(@receiver, targets: [target]) }
      end
    end
  end
end
