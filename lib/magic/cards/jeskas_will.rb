module Magic
  module Cards
    class JeskasWill < Sorcery
      card_name "Jeska's Will"
      cost generic: 2, red: 1

      # "Choose one. If you control a commander as you cast this spell, you may choose both instead."
      def modes_to_choose
        controls_commander? ? (1..2) : 1
      end

      def controls_commander?
        commander = controller.commander
        !!commander && controller.permanents.any? { |permanent| permanent.name == commander.name }
      end

      # "Add {R} for each card in target opponent's hand."
      class AddMana < Mode
        def target_choices = game.opponents(controller)

        def resolve!(target:)
          amount = target.hand.count
          controller.add_mana(red: amount) if amount.positive?
        end
      end

      # "Exile the top three cards of your library. You may play them this turn."
      class ExileTopThree < Mode
        def resolve!
          cards = controller.library.cards.first(3)
          cards.each do |card|
            card.exile!
            game.play_permissions.grant_until_end_of_turn(card: card, player: controller)
          end
        end
      end

      modes AddMana, ExileTopThree
    end
  end
end
