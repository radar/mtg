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
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: 2, filter: Filter[:basic_lands])
        end
      end

      # "You may sacrifice a land. If you do, search your library for up to two basic land cards, put them onto the
      # battlefield tapped, then shuffle."
      class EntersChoice < Magic::Choice::SacrificePermanent
        def initialize(actor:)
          super(actor: actor, type: "Land", other: false)
        end

        def resolve!(**)
          super
          game.add_choice(LandChoice.new(actor: actor))
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def call
          return unless controller.permanents.any? { _1.type?("Land") }

          game.add_choice(EntersChoice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
