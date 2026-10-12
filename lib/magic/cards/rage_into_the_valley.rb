module Magic
  module Cards
    class RageIntoTheValley < Sorcery
      card_name "Rage into the Valley"
      cost generic: 2, black: 1

      def resolve!
        trigger_effect(:draw_cards, source: self)
        trigger_effect(:lose_life, target: controller, life: 1)
        Magic::Amass.call(source: self, controller: controller, amount: 2)
      end
    end
  end
end
