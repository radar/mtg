module Magic
  module Cards
    BogBadger = Creature("Bog Badger") do
      cost generic: 2, green: 1
      creature_type "Badger"

      power 3
      toughness 3

      kicker_cost black: 1
    end

    class BogBadger < Creature
      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          if permanent.kicked?
            controller.creatures.each do |creature|
              creature.grant_keyword(:menace, until_eot: true)
            end
          end
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
