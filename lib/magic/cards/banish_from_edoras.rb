module Magic
  module Cards
    BanishFromEdoras = Sorcery("Banish from Edoras") do
      cost generic: 4, white: 1
    end

    class BanishFromEdoras < Sorcery
      def single_target? = true

      def target_choices = battlefield.creatures

      # "This spell costs {2} less to cast if it targets a tapped creature."
      def cost_change_for_targets(targets)
        target = targets.first
        target.is_a?(Magic::Permanent) && target.creature? && target.tapped? ? -2 : 0
      end

      # "Exile target creature."
      def resolve!(target:)
        exile_target(target)
      end
    end
  end
end
