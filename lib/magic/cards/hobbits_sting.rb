module Magic
  module Cards
    HobbitsSting = Instant("Hobbit's Sting") do
      cost generic: 1, white: 1
    end

    class HobbitsSting < Instant
      # "Hobbit's Sting deals X damage to target creature, where X is the number of creatures you control plus the
      # number of Foods you control." A Food creature counts twice.
      def target_choices = battlefield.creatures

      def resolve!(target:)
        x = controller.creatures.count + controller.permanents.count { _1.type?("Food") }
        deal_damage x, to: target
      end
    end
  end
end
