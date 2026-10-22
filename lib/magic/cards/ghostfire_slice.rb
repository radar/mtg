module Magic
  module Cards
    GhostfireSlice = Instant("Ghostfire Slice") do
      cost generic: 2, red: 1
      keywords :devoid
    end

    class GhostfireSlice < Instant
      # "This spell costs {2} less to cast if an opponent controls a multicolored permanent."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { battlefield.not_controlled_by(player).any? { _1.colors.size >= 2 } ? -2 : 0 } }
      end

      def target_choices = game.any_target

      # "...deals 4 damage to any target."
      def resolve!(target:)
        deal_damage(4, to: target)
      end
    end
  end
end
