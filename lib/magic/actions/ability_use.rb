module Magic
  module Actions
    # What mana paying for an activated ability is being spent on, as `Costs::Mana#for_use` (for "spend this mana only to
    # activate an ability"). `source` is the permanent, or the card for an ability used from hand or graveyard (Channel,
    # Renew, Cycling, Ninjutsu). Answers `type?` for the source so "...abilities of Elemental sources" restrictions work.
    # `mana_cost` is the ability's `Costs::Mana` being paid, so "costs that contain {X}" restrictions can inspect it.
    AbilityUse = Data.define(:source, :mana_cost) do
      def initialize(source:, mana_cost: nil) = super

      def type?(type) = source.type?(type)

      def x_cost? = !!mana_cost&.cost&.key?(:x)
    end
  end
end
