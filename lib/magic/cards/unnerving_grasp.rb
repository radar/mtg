module Magic
  module Cards
    class UnnervingGrasp < Sorcery
      card_name "Unnerving Grasp"
      cost generic: 2, blue: 1

      def multi_target? = true

      def target_choices
        [battlefield.permanents.reject(&:land?)]
      end

      # "Return up to one target nonland permanent to its owner's hand. Manifest dread."
      def resolve!(targets:)
        targets.first&.return_to_hand
        Magic::Choice::ManifestDread.perform(actor: self)
      end
    end
  end
end
