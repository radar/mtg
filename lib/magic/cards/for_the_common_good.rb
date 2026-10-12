module Magic
  module Cards
    class ForTheCommonGood < Sorcery
      card_name "For the Common Good"
      cost x: 2, green: 1

      def target_choices = battlefield.controlled_by(controller).select(&:token?)

      # Create X tokens that are copies of target token you control. Then tokens you control gain indestructible
      # until your next turn. You gain 1 life for each token you control.
      def resolve!(target:, value_for_x:)
        value_for_x.times do
          Permanent.token_copy(game: game, owner: controller, card: target.copiable_card)
        end
        tokens = battlefield.controlled_by(controller).select(&:token?)
        tokens.each { trigger_effect(:grant_keyword, target: _1, keyword: :indestructible) }
        trigger_effect(:gain_life, life: tokens.count)
      end
    end
  end
end
