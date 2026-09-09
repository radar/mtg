module Magic
  module Cards
    SpringbloomDruid = Creature("Springbloom Druid") do
      cost generic: 2, green: 1
      creature_type "Elf Druid"
      power 1
      toughness 1
    end

    class SpringbloomDruid < Creature
      class LandChoice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

      class EntersChoice < Magic::Choice::May
        def resolve!
          controller.permanents.lands.first&.sacrifice!
          game.add_choice(LandChoice.new(actor: actor))
        end
      end

      def etb_triggers
        [TriggeredAbility::EnterTheBattlefield]
      end
    end
  end
end