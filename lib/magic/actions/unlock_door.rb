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

      # The door's mana cost, less what static abilities say ("unlock costs you pay cost {1} less": a static ability
      # answering `unlock_cost_adjustment(door, player)` with a hash such as `{ generic: -1 }`, or nil).
      def mana_cost
        @mana_cost ||= Costs::Mana.new(door.cost.cost.dup).tap do |cost|
          cost.for_use = permanent.card
          game.battlefield.static_abilities.each do |ability|
            next unless ability.respond_to?(:unlock_cost_adjustment)

            adjustment = ability.unlock_cost_adjustment(door, player)
            cost.adjusted_by(adjustment) if adjustment
          end
        end
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
