module Magic
  module Cards
    RimeChill = Instant("Rime Chill") do
      cost generic: 6, blue: 1
    end

    class RimeChill < Instant
      # Vivid -- This spell costs {1} less to cast for each color among permanents you control.
      def self_mana_cost_adjustment
        { generic: -> { -(controller || owner).colors_among_permanents } }
      end

      def target_choices
        battlefield.creatures
      end

      # "Up to two target creatures": any number of targets from 0 to 2.
      def resolve!(targets: [])
        targets.first(2).each do |target|
          trigger_effect(:tap, target: target)
          trigger_effect(:add_counter, counter_type: "stun", target: target, amount: 1)
        end
        trigger_effect(:draw_cards, number_to_draw: 1)
      end
    end
  end
end
