module Magic
  module Cards
    class FungalRebirth < Instant
      card_name "Fungal Rebirth"
      cost generic: 2, green: 1

      SaprolingToken = Token.create "Saproling" do
        creature_type "Saproling"
        power 1
        toughness 1
        colors :green
      end

      def target_choices = controller.graveyard.permanents

      # "Return target permanent card from your graveyard to your hand. If a creature died this
      # turn, create two 1/1 green Saproling creature tokens."
      def resolve!(target:)
        target.move_to_hand!
        return unless game.current_turn.events.any? { |event| event.is_a?(Events::CreatureDied) }

        trigger_effect(:create_token, token_class: SaprolingToken, amount: 2)
      end
    end
  end
end
