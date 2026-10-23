module Magic
  module Cards
    MetastaticEvangel = Creature("Metastatic Evangel") do
      cost generic: 1, white: 1
      creature_type "Phyrexian Human Cleric"
      power 3
      toughness 1
    end

    class MetastaticEvangel < Creature
      # "Whenever another nontoken creature you control enters, proliferate."
      class CreatureEntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = another_creature? && under_your_control? && !event.permanent.token?

        def call
          proliferate
        end
      end

      def event_handlers = { Events::EnteredTheBattlefield => CreatureEntersTrigger }
    end
  end
end
