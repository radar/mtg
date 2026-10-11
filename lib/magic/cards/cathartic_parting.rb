module Magic
  module Cards
    class CatharticParting < Sorcery
      card_name "Cathartic Parting"
      cost generic: 1, green: 1

      GRAVEYARD_SLOTS = 4

      def multi_target? = true

      def distinct_targets? = true

      # The first target is an artifact or enchantment an opponent controls. The next four are "up to four target cards
      # from your graveyard": each slot offers your graveyard and may be left empty (`targeting(permanent, card, card)`).
      def target_choices
        graveyard = controller.graveyard.cards.to_a
        [
          battlefield.not_controlled_by(controller).select { _1.artifact? || _1.enchantment? },
          *Array.new(GRAVEYARD_SLOTS) { graveyard },
        ]
      end

      # "The owner of target artifact or enchantment an opponent controls shuffles it into their library. You may shuffle
      # up to four target cards from your graveyard into your library."
      def resolve!(targets:)
        permanent, *cards = targets
        game.add_effect(Effects::ShuffleIntoLibrary.new(source: self, target: permanent)) if permanent
        cards.each { |card| game.add_effect(Effects::ShuffleIntoLibrary.new(source: self, target: card)) if card.zone&.graveyard? }
      end
    end
  end
end
