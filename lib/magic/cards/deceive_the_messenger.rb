module Magic
  module Cards
    DeceiveTheMessenger = Instant("Deceive the Messenger") do
      cost blue: 1
    end

    class DeceiveTheMessenger < Instant
      def single_target? = true

      def target_choices = battlefield.creatures

      # "Target creature gets -3/-0 until end of turn. Amass Orcs 1."
      def resolve!(target:)
        pump(target, -3, 0)
        Magic::Amass.call(source: self, controller: controller, amount: 1, subtype: "Orc")
        super()
      end
    end
  end
end
