module Magic
  module Cards
    PathOfAncestry = Card("Path of Ancestry") do
      type "Land"
    end

    # The "when that mana is spent to cast a creature spell that shares a creature type with your
    # commander, scry 1" rider is not modelled: the engine doesn't track which source produced the
    # mana spent on a spell.
    class PathOfAncestry < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        def choices
          Array(controller.commander&.color_identity)
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
