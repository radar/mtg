module Magic
  module Cards
    EclipsedRealms = Card("Eclipsed Realms") do
      type T::Land
    end

    class EclipsedRealms < Card
      TYPES = %w[Elemental Elf Faerie Giant Goblin Kithkin Merfolk Treefolk].freeze

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(Magic::Choice::ChooseCreatureTypeForPermanent.new(actor: actor, options: TYPES))
        end
      end

      def etb_triggers = [ETB]

      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      # {T}: Add one mana of any color. Spend this mana only to cast a spell of the chosen type
      # or activate an ability of a source of the chosen type.
      class ChosenTypeManaAbility < Magic::TapManaAbility
        choices :all

        def mana_restriction = ManaRestriction::ChosenType.new(source: source)
      end

      def activated_abilities = [ColorlessManaAbility, ChosenTypeManaAbility]
    end
  end
end
