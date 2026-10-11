module Magic
  module Actions
    # Special action (rule 116.2k): pay a locked door's mana cost to unlock it, any time you could cast a sorcery.
    class UnlockDoor < Action
      attr_reader :permanent, :door

      def initialize(permanent:, door:, **args)
        @permanent = permanent
        @door = permanent.card.door(door)
        super(**args)
      end

      def inspect
        "#<Actions::UnlockDoor door: #{door.name}, player: #{player.inspect}>"
      end

      def uses_priority? = false

      def mana_cost
        @mana_cost ||= Costs::Mana.new(door.cost.cost.dup).tap { |cost| cost.for_use = permanent.card }
      end

      def pay_mana(payment)
        mana_cost.pay(player: player, payment: payment)
        self
      end

      def can_perform?
        mana_cost.can_pay?(player)
      end

      def illegal_reason
        return "#{permanent.name} is not a Room" unless permanent.card.is_a?(Cards::Room)
        return "#{permanent.name} is not on the battlefield" unless permanent.zone&.battlefield?
        return "#{player.inspect} does not control #{permanent.name}" unless permanent.controller == player
        return "#{door.name} is already unlocked" if permanent.card.unlocked?(door)

        reason = sorcery_speed_reason
        "doors can only be unlocked at sorcery speed, but #{reason}" if reason
      end

      def perform
        mana_cost.finalize!(player)
        permanent.unlock_door!(door)
      end
    end
  end
end
