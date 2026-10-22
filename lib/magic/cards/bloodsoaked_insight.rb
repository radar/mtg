module Magic
  module Cards
    # The land back face of Bloodsoaked Insight. It has no mana cost.
    SanguineMorass = Card("Sanguine Morass") do
      type "Land"
    end

    class SanguineMorass < Card
      def enters_tapped? = true

      class ManaAbility < Magic::TapManaAbility
        choices :black, :red
      end

      def activated_abilities = [ManaAbility]
    end

    BloodsoakedInsight = Sorcery("Bloodsoaked Insight") do
      cost "{5}{B/R}{B/R}"
      back_face SanguineMorass
    end

    class BloodsoakedInsight < Sorcery
      # "This spell costs {1} less to cast for each 1 life your opponents have lost this turn."
      def self_mana_cost_adjustment
        player = controller || owner
        { generic: -> { -player.opponents_life_lost_this_turn } }
      end

      def target_choices = game.opponents(controller)

      # "Target opponent exiles the top three cards of their library. Until the end of your next turn, you may play
      # those cards. If you cast a spell this way, mana of any type can be spent to cast it."
      def resolve!(target:)
        target.library.take(3).each do |card|
          exile_target(card)
          game.play_permissions.grant_until_end_of_next_turn(card:, player: controller, any_mana: true)
        end
      end
    end
  end
end
