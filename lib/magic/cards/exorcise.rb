module Magic
  module Cards
    Exorcise = Sorcery("Exorcise") do
      cost generic: 1, white: 1
    end

    class Exorcise < Sorcery
      # "Exile target artifact, enchantment, or creature with power 4 or greater."
      def target_choices
        battlefield.permanents.select do |permanent|
          permanent.artifact? || permanent.enchantment? || (permanent.creature? && permanent.power >= 4)
        end
      end

      def resolve!(target:)
        trigger_effect(:exile, target: target)
      end
    end
  end
end
