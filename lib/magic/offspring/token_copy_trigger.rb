module Magic
  module Offspring
    # "When this creature enters, if its offspring cost was paid, create a 1/1 token
    # copy of it." Queued by Actions::Cast#resolve! as the creature enters.
    class TokenCopyTrigger < TriggeredAbility
      def call
        token = Permanent.resolve(
          game: game,
          owner: controller,
          card: actor.copiable_card,
          token: true,
          copy: true,
          cast: false,
        )
        token.modify_base_power(1, until_eot: false)
        token.modify_base_toughness(1, until_eot: false)
      end
    end
  end
end
