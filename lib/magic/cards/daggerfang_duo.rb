module Magic
  module Cards
    DaggerfangDuo = Creature("Daggerfang Duo") do
      cost generic: 2, black: 1
      creature_type("Rat Squirrel")
      keywords :deathtouch
      power 3
      toughness 2
    end

    class DaggerfangDuo < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            controller.mill(2)
          end
        end

        def call
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
