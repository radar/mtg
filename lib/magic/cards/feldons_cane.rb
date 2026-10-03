module Magic
  module Cards
    FeldonsCane = Artifact("Feldon's Cane") do
      cost generic: 1
    end

    class FeldonsCane < Artifact
      class ActivatedAbility < Magic::ActivatedAbility
        costs "{T}, Exile {this}"

        def resolve!
          [*controller.graveyard.cards].each { _1.move_zone!(to: controller.library) }
          controller.shuffle!
        end
      end

      def activated_abilities = [ActivatedAbility]
    end
  end
end
