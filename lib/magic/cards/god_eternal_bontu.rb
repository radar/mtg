module Magic
  module Cards
    GodEternalBontu = Creature("God-Eternal Bontu") do
      legendary_creature_type "Zombie God"
      cost generic: 3, black: 2
      power 5
      toughness 6
      keywords :menace
    end

    class GodEternalBontu < Creature
      class SacrificeChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.permanents.except(actor)
          super
        end

        def resolve!(targets:)
          targets.each(&:sacrifice!)
          targets.count.times { controller.draw! }
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(SacrificeChoice.new(actor: actor))
        end
      end

      def event_handlers
        { Events::EnteredTheBattlefield => EntersTrigger }
      end
    end
  end
end