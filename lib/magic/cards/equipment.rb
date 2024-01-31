module Magic
  module Cards
    class Equipment < Card
      TYPE_LINE = "Artifact -- Equipment"

      def self.equip(equip_cost)
        equip = Class.new(ActivatedAbility) do
          define_method(:costs) { equip_cost }

          def target_choices
            game.battlefield.creatures.controlled_by(controller)
          end

          def resolve!(target:)
            target.attachments << source
          end
        end

        define_method(:activated_abilities) do
          [equip]
        end
      end

      def resolve!(target:)
        permanent = super()
        permanent.attach_to!(target)
      end

      def single_target?
        true
      end

      def resolve!(target:)
        permanent = super()
        permanent.attach_to!(target)
      end

      def power_modification
        0
      end

      def toughness_modification
        0
      end

      def keyword_grants
        []
      end

      def type_grants
        []
      end

      def can_activate_ability?(_)
        true
      end
    end
  end
end
