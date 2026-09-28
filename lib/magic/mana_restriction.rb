module Magic
  # "Spend this mana only to ..." A restriction rides on each unit of restricted mana in
  # `Player#restricted_mana`; `Costs::Mana` only counts a unit toward a payment when
  # `permits?` says so. `use` is what the mana is being spent on: the spell's card when
  # casting, or the source permanent when activating an ability.
  class ManaRestriction
    def permits?(_use)
      raise NotImplementedError, "#{self.class} must implement #permits?(use)"
    end

    # "Spend this mana only to cast a spell of the chosen type or activate an ability of a
    # source of the chosen type." `source` is the permanent holding the chosen creature type.
    class ChosenType < ManaRestriction
      def initialize(source:)
        @source = source
      end

      def permits?(use)
        type = @source.chosen_creature_type
        !type.nil? && use.respond_to?(:type?) && use.type?(type)
      end
    end
  end
end
