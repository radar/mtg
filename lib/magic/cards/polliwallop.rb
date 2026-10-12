module Magic
  module Cards
    class Polliwallop < Instant
      card_name "Polliwallop"
      cost generic: 3, green: 1

      # Affinity for Frogs: this spell costs {1} less to cast for each Frog you control.
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -player.creatures.count { _1.type?("Frog") } } }
      end

      def multi_target? = true

      def target_choices
        [battlefield.controlled_by(controller).creatures, battlefield.not_controlled_by(controller).creatures]
      end

      # Target creature you control deals damage equal to twice its power to target creature you don't control.
      def resolve!(targets:)
        mine, theirs = targets
        deal_damage(mine.power * 2, to: theirs)
      end
    end
  end
end
