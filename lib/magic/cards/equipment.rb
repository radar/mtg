module Magic
  module Cards
    class Equipment < Attachment
      TYPE_LINE = [T::Artifact, "Equipment"].freeze

      def self.equip(equip_cost)
        equip = Class.new(ActivatedAbility) do
          # Fresh costs per activation: a cost tracks what's been paid towards it,
          # so reusing one would leave it paid after the first equip.
          define_method(:costs) do
            equip_cost.map { |cost| cost.is_a?(Costs::Mana) ? Costs::Mana.new(cost.cost.dup) : cost }
          end

          def target_choices
            creatures_you_control
          end

          def resolve!(target:)
            source.attach_to!(target)
          end
        end

        define_method(:activated_abilities) do
          [equip]
        end
      end
    end
  end
end
