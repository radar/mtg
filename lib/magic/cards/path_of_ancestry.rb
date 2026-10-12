module Magic
  module Cards
    PathOfAncestry = Card("Path of Ancestry") do
      type "Land"
    end

    class PathOfAncestry < Card
      def enters_tapped? = true

      # "{T}: Add one mana of any color in your commander's color identity. When that mana is spent to cast a creature
      # spell that shares a creature type with your commander, scry 1." The mana carries a ManaRestriction that permits
      # everything but is told what it was spent on (see Player#spend_restricted_mana).
      class ManaAbility < Magic::TapManaAbility
        def choices
          Array(controller.commander&.color_identity)
        end

        def mana_restriction = ManaRestriction::ScryForCommanderType.new(source: source)
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
