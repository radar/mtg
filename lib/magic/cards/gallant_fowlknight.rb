module Magic
  module Cards
    GallantFowlknight = Creature("Gallant Fowlknight") do
      cost generic: 3, white: 1
      creature_type("Kithkin Knight")
      power 3
      toughness 4
    end

    class GallantFowlknight < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          battlefield.controlled_by(controller).creatures.each do |creature|
            pump(creature, 1, 0)
            creature.grant_keyword(Cards::Keywords::FIRST_STRIKE, until_eot: true) if creature.type?("Kithkin")
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
