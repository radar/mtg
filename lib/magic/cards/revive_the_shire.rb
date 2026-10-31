module Magic
  module Cards
    ReviveTheShire = Sorcery("Revive the Shire") do
      cost generic: 1, green: 1
    end

    class ReviveTheShire < Sorcery
      def target_choices = controller.graveyard.permanents

      # "Return target permanent card from your graveyard to your hand. Create a Food token."
      def resolve!(target:)
        move_card(target, to: controller.hand, from: controller.graveyard)
        create_token(token: Tokens::Food)
      end
    end
  end
end
