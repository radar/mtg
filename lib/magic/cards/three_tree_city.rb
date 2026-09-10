module Magic
  module Cards
    ThreeTreeCity = Card("Three Tree City") do
      type T::Super::Legendary, T::Land
    end

    class ThreeTreeCity < Card
      attr_accessor :chosen_creature_type

      class CreatureTypeChoice < Magic::Choice::CreatureType
        def resolve!(creature_type:)
          actor.card.chosen_creature_type = creature_type
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ThreeTreeCity::CreatureTypeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]

      class ColorlessManaAbility < Magic::TapManaAbility
        choices :colorless
      end

      class ChosenTypeManaAbility < Magic::ManaAbility
        costs "{2}, {T}"
        choices :all

        def mana_produced
          count = source.controller.creatures.by_type(source.card.chosen_creature_type).count
          { choice => count }
        end
      end

      def activated_abilities = [ColorlessManaAbility, ChosenTypeManaAbility]
    end
  end
end
