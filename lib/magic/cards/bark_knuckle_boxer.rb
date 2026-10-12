module Magic
  module Cards
    BarkKnuckleBoxer = Creature("Bark-Knuckle Boxer") do
      cost generic: 1, green: 1
      creature_type("Raccoon Berserker")
      power 3
      toughness 2
    end

    class BarkKnuckleBoxer < Creature
      # Whenever you expend 4, this creature gains indestructible until end of turn.
      class ExpendTrigger < TriggeredAbility::Expend
        def threshold = 4

        def call
          give_keyword(actor, :indestructible)
        end
      end

      def event_handlers = super.merge(ExpendTrigger.handlers)
    end
  end
end
