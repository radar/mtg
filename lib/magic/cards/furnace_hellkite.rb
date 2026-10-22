module Magic
  module Cards
    class FurnaceHellkite < Creature
      card_name "Furnace Hellkite"
      artifact_creature_type "Dragon"
      cost generic: 5, red: 2
      keywords :flying
      power 5
      toughness 5

      # Affinity for artifacts: "This spell costs {1} less to cast for each artifact you control."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -battlefield.controlled_by(player).count(&:artifact?) } }
      end

      # "{R}: This creature gets +1/+0 until end of turn."
      class FirebreathingAbility < Magic::ActivatedAbility
        costs "{R}"

        def resolve!
          pump(source, 1, 0)
        end
      end

      def activated_abilities = [FirebreathingAbility]
    end
  end
end
