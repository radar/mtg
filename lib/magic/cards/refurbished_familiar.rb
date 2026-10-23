module Magic
  module Cards
    RefurbishedFamiliar = Creature("Refurbished Familiar") do
      artifact_creature_type("Zombie Rat")
      cost generic: 3, black: 1
      power 2
      toughness 1
      keywords :flying
    end

    class RefurbishedFamiliar < Creature
      # "Affinity for artifacts (This spell costs {1} less to cast for each artifact you control.)"
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -[game.battlefield.controlled_by(player).count { _1.type?("Artifact") }, 3].min } }
      end

      # "When this creature enters, each opponent discards a card. For each opponent who can't, you draw a card."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          opponents.each do |opponent|
            if opponent.hand.any?
              game.add_choice(Magic::Choice::Discard.new(player: opponent, actor: actor))
            else
              draw_card
            end
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
