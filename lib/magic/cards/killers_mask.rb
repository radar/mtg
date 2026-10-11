module Magic
  module Cards
    class KillersMask < Equipment
      card_name "Killer's Mask"
      cost generic: 2, black: 1
      equip [Costs::Mana.new(generic: 2)]

      # "When this Equipment enters, manifest dread, then attach this Equipment to that creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDreadAndAttach.perform(actor: actor)
        end
      end

      # "Equipped creature has menace."
      class MenaceGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::MENACE
        applies_to_target
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [MenaceGrant]
    end
  end
end
