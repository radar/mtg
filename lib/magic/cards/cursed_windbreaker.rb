module Magic
  module Cards
    class CursedWindbreaker < Equipment
      card_name "Cursed Windbreaker"
      cost generic: 2, blue: 1
      equip [Costs::Mana.new(generic: 3)]

      # "When this Equipment enters, manifest dread, then attach this Equipment to that creature."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          Magic::Choice::ManifestDreadAndAttach.perform(actor: actor)
        end
      end

      # "Equipped creature has flying."
      class FlyingGrant < Abilities::Static::KeywordGrant
        keyword_grants Keywords::FLYING
        applies_to_target
      end

      def etb_triggers = [EntersTrigger]
      def static_abilities = [FlyingGrant]
    end
  end
end
