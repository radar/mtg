module Magic
  class Choice
    # "You may sacrifice another creature. If you do, ...": accepting (`game.resolve_choice!`, optionally
    # with `sacrifice:` naming which permanent, else the first candidate) sacrifices it; declining
    # (`game.skip_choice!`) does nothing. The effects after "If you do" are run by a subclass after
    # `super`, so they never run when declined. Callers add it only when there is something to
    # sacrifice (`candidates.any?`).
    class SacrificePermanent < Magic::Choice::May
      attr_reader :type, :other

      def initialize(actor:, type: "Creature", other: true)
        @type = type
        @other = other
        super(actor: actor)
      end

      def candidates
        controller.permanents.select { _1.type?(type) && !(other && _1 == actor) }
      end

      def resolve!(sacrifice: nil)
        sacrifice ||= candidates.first
        raise ArgumentError, "can't sacrifice #{sacrifice&.name.inspect}" unless candidates.include?(sacrifice)

        sacrifice.sacrifice!
      end
    end
  end
end
