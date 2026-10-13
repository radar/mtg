module Magic
  module Cards
    class FeedTheSwarm < Sorcery
      card_name "Feed the Swarm"
      cost generic: 1, black: 1

      def single_target? = true

      def target_choices
        battlefield.not_controlled_by(controller).select { _1.creature? || _1.enchantment? }
      end

      # "Destroy target creature or enchantment an opponent controls. You lose life equal to that permanent's mana value."
      def resolve!(target:)
        life = target.mana_value
        destroy(target)
        lose_life(controller, life)
      end
    end
  end
end
