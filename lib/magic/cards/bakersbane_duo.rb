module Magic
  module Cards
    BakersbaneDuo = Creature("Bakersbane Duo") do
      cost generic: 1, green: 1
      creature_type("Squirrel Raccoon")
      power 2
      toughness 2
    end

    class BakersbaneDuo < Creature
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          trigger_effect(:create_token, token_class: Tokens::Food)
        end
      end

      def etb_triggers = [EntersTrigger]

      # Whenever you expend 4, this creature gets +1/+1 until end of turn.
      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          pump(actor, 1, 1)
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
