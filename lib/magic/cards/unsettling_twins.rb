module Magic
  module Cards
    UnsettlingTwins = Creature("Unsettling Twins") do
      cost generic: 3, white: 1
      creature_type "Human"
      power 2
      toughness 2
    end

    class UnsettlingTwins < Creature
      # "When this creature enters, manifest dread."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDread.perform(actor: actor)
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
