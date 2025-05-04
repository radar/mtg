module Magic
  module Cards
    OdricLunarchMarshal = Creature("Odric, Lunarch Marshal") do
      type T::Super::Legendary, T::Creature, *creature_types("Human Soldier")
      cost generic: 3, white: 1
      power 3
      toughness 3
    end

    class OdricLunarchMarshal < Creature
      class BeginningOfCombatTrigger < TriggeredAbility
        def call
          applicable_keywords = Keywords.list(
            :first_strike,
            :flying,
            :deathtouch,
            :double_strike,
            :haste,
            :indestructible,
            :lifelink,
            :reach,
            :skulk,
            :trample,
            :vigilance,
          )

          applicable_keywords.each do |keyword|
            next unless controller.creatures.any? { |creature| creature.has_keyword?(keyword) }

            controller.creatures.each do |creature|
              next if creature.has_keyword?(keyword)
              creature.grant_keyword(keyword, until_eot: true)
            end
          end
        end
      end

      def event_handlers
        {
          Events::BeginningOfCombat => BeginningOfCombatTrigger
        }
      end
    end
  end
end
