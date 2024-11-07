module Magic
  module Cards
    class Equipment < Attachment
      TYPE_LINE = "Artifact -- Equipment"

      def self.equip(equip_cost)
        equip = Class.new(ActivatedAbility) do
          define_method(:costs) { equip_cost }

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
