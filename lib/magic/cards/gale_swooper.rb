module Magic
  module Cards
    GaleSwooper = Creature("Gale Swooper") do
      cost generic: 3, white: 1
      creature_type("Griffin")
      power 3
      toughness 2
    end

    class GaleSwooper < Creature
      class Choice < Magic::Choice
        def resolve!(target:)
          target.grant_keyword(Keywords::FLYING, until_eot: true)
        end
      end

      class ETB < TriggeredAbility::EnterTheBattlefield
        def perform
          game.choices.add(Choice.new(actor: actor))
        end
      end

      def etb_triggers = [ETB]
    end
  end
end
