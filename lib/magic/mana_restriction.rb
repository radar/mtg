module Magic
  # "Spend this mana only to ..." A restriction rides on each unit of restricted mana in
  # `Player#restricted_mana`; `Costs::Mana` only counts a unit toward a payment when
  # `permits?` says so. `use` is what the mana is being spent on: the spell's card when
  # casting, or the source permanent when activating an ability.
  class ManaRestriction
    def permits?(_use)
      raise NotImplementedError, "#{self.class} must implement #permits?(use)"
    end

    # "Spend this mana only to cast spells with mana value 4 or greater." Only spells (a card
    # being cast), not abilities of a permanent.
    class MinimumManaValue < ManaRestriction
      def initialize(minimum)
        @minimum = minimum
      end

      def permits?(use)
        use.is_a?(Magic::Card) && use.mana_value >= @minimum
      end
    end

    # "Spend this mana only to cast a legendary spell" (Plaza of Heroes). Only spells, not abilities.
    class LegendarySpell < ManaRestriction
      def permits?(use)
        use.is_a?(Magic::Card) && use.legendary?
      end
    end

    # Path of Ancestry: "When that mana is spent to cast a creature spell that shares a creature type with your
    # commander, scry 1." Not a restriction at all (any spend is allowed), but riding on the mana lets `spent_on` see what
    # it was spent on.
    class ScryForCommanderType < ManaRestriction
      def initialize(source:)
        @source = source
      end

      def permits?(_use) = true

      def spent_on(use, player)
        commander = player.commander
        return unless commander && use.is_a?(Magic::Card) && use.creature?

        shared = (use.types & commander.types).any? { |type| Magic::Types::Creatures.values.include?(type) }
        player.game.choices.add(Magic::Choice::Scry.new(actor: @source)) if shared
      end
    end

    # "Spend this mana only to cast Elemental spells or activate abilities of Elemental sources."
    class OfType < ManaRestriction
      def initialize(type:)
        @type = type
      end

      def permits?(use)
        use.respond_to?(:type?) && use.type?(@type)
      end
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
