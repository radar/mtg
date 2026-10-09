module Magic
  module Cards
    OldThrush = Creature("Old Thrush") do
      cost generic: 2
      creature_type("Bird")
      keywords :flying
      power 1
      toughness 2
    end

    class OldThrush < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        class MayChoice < Magic::Choice::May
          def resolve!
            game.choices.add(Magic::Choice::SearchLibrary.new(actor: actor, to_zone: :top, enters_tapped: false, upto: 1, filter: Filter[:basic_lands], reveal: true))
          end
        end

        def call
          trigger_effect(:gain_life, target: controller, life: 2)
          game.choices.add(MayChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
