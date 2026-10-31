module Magic
  module Cards
    SarumansTrickery = Instant("Saruman's Trickery") do
      cost generic: 1, blue: 2
    end

    class SarumansTrickery < Instant
      def single_target? = true

      def target_choices = game.stack.spells

      # "Counter target spell. Amass Orcs 1."
      def resolve!(target:)
        counter_spell(target)
        Magic::Amass.call(source: self, controller: controller, amount: 1, subtype: "Orc")
        super()
      end
    end
  end
end
