module Magic
  class Choice
    # "Exile an Elf card from your graveyard": the controller picks one matching card from their
    # graveyard to exile (`choices` is empty when there is none).
    class ExileFromGraveyard < Choice
      attr_reader :type

      def initialize(actor:, type:)
        @type = type
        super(actor: actor)
      end

      def choices = controller.graveyard.cards.select { _1.type?(type) }

      def resolve!(target:)
        raise ArgumentError, "#{target.name} isn't an #{type} card in your graveyard" unless choices.include?(target)

        trigger_effect(:exile, target:)
      end
    end
  end
end
