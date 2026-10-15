module Magic
  module Actions
    # What mana paying for an activated ability is being spent on, as `Costs::Mana#for_use` (for "spend this mana only to
    # activate an ability"). `source` is the permanent, or the card for an ability used from hand or graveyard (Channel,
    # Renew, Cycling, Ninjutsu). Answers `type?` for the source so "...abilities of Elemental sources" restrictions work.
    AbilityUse = Data.define(:source) do
      def type?(type) = source.type?(type)
    end
  end
end
