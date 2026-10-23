module Magic
  module Cards
    class LethalThrowdown < Sorcery
      card_name "Lethal Throwdown"
      cost black: 1

      attr_writer :sacrificed_modified

      # Remembers whether the sacrificed creature was modified, since counters and attachments are gone afterwards.
      class SacrificeRememberingModified < Costs::Sacrifice
        def pay(payment:)
          permanent.sacrificed_modified = payment.modified?
          super
        end
      end

      # "As an additional cost to cast this spell, sacrifice a creature or sacrifice a modified creature."
      def additional_costs
        [SacrificeRememberingModified.new(self, controller.creatures)]
      end

      def target_choices = battlefield.creatures + battlefield.planeswalkers

      # "Destroy target creature or planeswalker. If the modified creature was sacrificed, draw a card."
      def resolve!(target:)
        destroy(target)
        draw_cards(1) if @sacrificed_modified
      end
    end
  end
end
