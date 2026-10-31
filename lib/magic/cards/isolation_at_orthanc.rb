module Magic
  module Cards
    IsolationAtOrthanc = Instant("Isolation at Orthanc") do
      cost generic: 3, blue: 1
    end

    class IsolationAtOrthanc < Instant
      def target_choices = battlefield.creatures

      # "Put target creature into its owner's library second from the top."
      def resolve!(target:)
        library = target.owner.library
        # Leaving the battlefield for real, so leaves-the-battlefield triggers see it go.
        target.move_zone!(to: library)
        return if target.copy? || target.token?

        move_card(target.card, to: library, placement: [1, library.count].min)
      end
    end
  end
end
