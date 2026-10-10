module Magic
  class Choice
    # "You may behold a Dragon. If you do, ...": to behold a Dragon, choose a Dragon you control or
    # reveal a Dragon card from your hand. Accepting (`game.resolve_choice!`, optionally with
    # `beheld:` naming which candidate, else the first) reveals it; declining (`game.skip_choice!`)
    # does nothing. The effects after "If you do" are run by a subclass after `super`, so they never
    # run when declined. Callers add it only when there is something to behold (`candidates.any?`).
    class Behold < Magic::Choice::May
      attr_reader :type

      def initialize(actor:, type:)
        @type = type
        super(actor: actor)
      end

      # Permanents of the type you control, then cards of the type in your hand.
      def candidates
        [*chooser.permanents.select { _1.type?(type) }, *hand.cards.select { _1.type?(type) }]
      end

      def resolve!(beheld: nil)
        beheld ||= candidates.first
        raise ArgumentError, "can't behold #{beheld&.name.inspect} as a #{type}" unless candidates.include?(beheld)

        beheld.reveal! if beheld.is_a?(Magic::Card)
      end
    end
  end
end
