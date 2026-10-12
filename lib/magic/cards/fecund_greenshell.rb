module Magic
  module Cards
    FecundGreenshell = Creature("Fecund Greenshell") do
      cost generic: 3, green: 2
      creature_type("Elemental Turtle")
      keywords :reach
      power 4
      toughness 6
    end

    class FecundGreenshell < Creature
      # As long as you control ten or more lands, creatures you control get +2/+2.
      class LandsBuff < Abilities::Static::PowerAndToughnessModification
        modify power: 2, toughness: 2

        def applicable_targets
          source.controller.lands.count >= 10 ? source.controller.creatures : []
        end
      end

      def static_abilities = [LandsBuff]

      # Whenever this creature or another creature you control with toughness greater than its power enters, look
      # at the top card of your library. If it's a land card, you may put it onto the battlefield tapped.
      # Otherwise, put it into your hand.
      class CreatureEnters < TriggeredAbility::EnterTheBattlefield
        class MayPlayLand < Magic::Choice::May
          def initialize(actor:, land:)
            @land = land
            super(actor: actor)
          end

          def resolve!
            Permanent.resolve(card: @land, game: game, from_zone: @land.zone, cast: false, controller: controller, enters_tapped: true)
          end

          def decline!
            @land.move_to_hand!
          end
        end

        def should_perform?
          creature? && under_your_control? && event.permanent.toughness > event.permanent.power
        end

        def call
          top = controller.library.first or return

          if top.land?
            game.choices.add(MayPlayLand.new(actor: actor, land: top))
          else
            top.move_to_hand!
          end
        end
      end

      def event_handlers = super.merge(Events::EnteredTheBattlefield => CreatureEnters)
    end
  end
end
