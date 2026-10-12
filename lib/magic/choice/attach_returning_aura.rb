module Magic
  class Choice
    # An Aura put onto the battlefield without being cast (returned from exile or a graveyard) is attached to something its
    # owner chooses (rule 303.4f). The actor is the Aura card; what it can enchant is its `target_choices`.
    class AttachReturningAura < Targeted
      def choices = actor.target_choices

      def choice_amount = 1

      def resolve!(target:)
        actor.resolve!(target: target)
      end
    end
  end
end
