module Magic
  class Choice
    # "Exile up to one target Equipment attached to that creature." (Fiery Annihilation). The Equipment is
    # chosen as the spell resolves (`game.resolve_choice!(target: equipment)`, or `game.skip_choice!` for none),
    # not as it is cast. `actor` is the spell, `creature` the permanent the Equipment is attached to. The
    # candidates are fixed when the choice is made: the creature may die (and so unattach them) before it is
    # answered, but the spell exiles the Equipment while it is still attached.
    class ExileAttachedEquipment < Magic::Choice::Targeted
      attr_reader :creature, :choices

      def initialize(actor:, creature:)
        super(actor: actor)
        @creature = creature
        @choices = creature.attachments.select { _1.type?("Equipment") }
      end

      # A range, so Stack#add_choice doesn't pick a lone Equipment for you.
      def choice_amount = 0..1

      def resolve!(target:)
        raise ArgumentError, "#{target.name} is not Equipment attached to #{creature.name}" unless choices.include?(target)

        trigger_effect(:exile, target: target)
      end
    end
  end
end
