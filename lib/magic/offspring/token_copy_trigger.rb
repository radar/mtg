module Magic
  module Offspring
    # "When this creature enters, if its offspring cost was paid, create a 1/1 token
    # copy of it." Queued by Actions::Cast#resolve! as the creature enters.
    class TokenCopyTrigger < TriggeredAbility
      def call
        trigger_effect(:create_token_copy, card: actor.copiable_card, base_power: 1, base_toughness: 1)
      end
    end
  end
end
