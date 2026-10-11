module Magic
  # Suspend (rule 702.62). `Actions::Suspend` exiles the card with time counters; this trigger runs from exile at the
  # beginning of its owner's upkeep.
  module Suspend
    # Casts +card+ from exile without paying its mana cost, at +target+ when it needs one.
    def self.cast_free(card, target: nil)
      card.owner.cast(card: card, by_effect: true) do |action|
        action.mana_cost = 0
        action.targeting(target) if target
      end
    end

    # "At the beginning of your upkeep, if this card is suspended, remove a time counter from it. When the last is removed,
    # cast it without paying its mana cost if able."
    class UpkeepTrigger < TriggeredAbility
      def self.works_from_exile? = true

      def should_perform?
        actor.suspended? && event.player == actor.owner
      end

      # Picks the target of the free cast (a spell that needs one) as a choice.
      class TargetChoice < Magic::Choice::Targeted
        attr_reader :spell

        def initialize(actor:, spell:)
          super(actor: actor)
          @spell = spell
        end

        def prompt = "Choose a target for #{spell.name}."

        def choices = spell.target_choices.to_a

        def choice_amount = 1

        def resolve!(target:)
          Suspend.cast_free(spell, target: target)
        end
      end

      def call
        actor.time_counters -= 1
        return if actor.time_counters.positive?

        actor.time_counters = nil
        if actor.respond_to?(:target_choices) && actor.target_choices.any?
          game.add_choice(TargetChoice.new(actor: actor, spell: actor))
        elsif !actor.respond_to?(:target_choices)
          Suspend.cast_free(actor)
        end
      end
    end
  end
end
