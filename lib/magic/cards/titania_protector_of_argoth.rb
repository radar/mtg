module Magic
  module Cards
    TitaniaProtectorOfArgoth = Creature("Titania, Protector of Argoth") do
      legendary_creature_type "Elemental"
      cost generic: 3, green: 2
      power 5
      toughness 3
    end

    class TitaniaProtectorOfArgoth < Creature
      ElementalToken = Token.create("Elemental") do
        creature_type "Elemental"
        power 5
        toughness 3
        colors :green
      end

      class LandChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.graveyard.cards.lands
          super
        end

        def resolve!(target:)
          target.resolve!
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          choice = LandChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      class LandLeftBattlefieldTrigger < TriggeredAbility
        def should_perform?
          event.permanent.land? &&
            event.permanent.controller == controller &&
            event.from.battlefield? && event.to.graveyard?
        end

        def call
          actor.create_token(token_class: ElementalToken)
        end
      end

      def event_handlers
        {
          Events::EnteredTheBattlefield => EntersTrigger,
          Events::PermanentLeavingZone => LandLeftBattlefieldTrigger,
        }
      end
    end
  end
end