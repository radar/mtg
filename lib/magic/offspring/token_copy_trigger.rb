module Magic
  module Offspring
    # "When this creature enters, if its offspring cost was paid, create a 1/1 token
    # copy of it." Queued by Actions::Cast#resolve! as the creature enters.
    class TokenCopyTrigger < TriggeredAbility
      def call
        copy_as_token(actor.copiable_card, base_power: 1, base_toughness: 1)
      end
    end
  end
end
