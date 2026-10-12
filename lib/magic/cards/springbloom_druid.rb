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
          super(actor: actor, to_zone: :battlefield, enters_tapped: true, upto: 2, filter: Filter[:basic_lands],
                prompt: "Search your library for up to two basic land cards. They enter the battlefield tapped.")
        end
      end

      # "You may sacrifice a land. If you do, search your library for up to two basic land cards, put them onto the
      # battlefield tapped, then shuffle."
      class EntersChoice < Magic::Choice::SacrificePermanent
        def prompt = "Sacrifice a land? If you do, search your library for up to two basic land cards."

        def initialize(actor:)
          super(actor: actor, type: "Land", other: false)
        end

        # Names `sacrifice:` so a UI can offer the choice of which land (see ChoicePrompt#may_with_sacrifice?).
        def resolve!(sacrifice: nil)
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
