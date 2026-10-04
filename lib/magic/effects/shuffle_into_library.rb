module Magic
  module Effects
    # Puts a card (or a permanent and its card) into its owner's library, then shuffles it:
    # "reveal ~ and shuffle it into its owner's library instead" (Darksteel Colossus, Progenitus).
    class ShuffleIntoLibrary < TargetedEffect
      def inspect
        "#<Effects::ShuffleIntoLibrary source:#{source.name} target:#{target.name}>"
      end

      def resolve!
        owner = target.owner
        if target.is_a?(Permanent)
          target.move_zone!(to: owner.library)
          target.card.move_zone!(to: owner.library) unless target.copy? || target.token?
        else
          target.move_zone!(to: owner.library)
        end
        owner.shuffle!
      end
    end
  end
end
