module Magic
  module Cards
    MultaniYavimayasAvatar = Creature("Multani, Yavimaya's Avatar") do
      legendary_creature_type "Elemental Avatar"
      cost generic: 4, green: 2
      keywords :reach, :trample
    end

    class MultaniYavimayasAvatar < Creature
      class DynamicPowerAndToughness < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification
          source.controller.lands.count + source.controller.graveyard.lands.count
        end

        alias_method :toughness_modification, :power_modification
      end

      class ReturnFromGraveyardAbility < Magic::ActivatedAbility
        costs "{1}{G}, Return two lands you control to their owner's hand"

        def requirements_met?
          source.zone&.graveyard? && source.owner == controller
        end

        def resolve!
          source.move_to_hand!(source.owner)
        end
      end

      def static_abilities = [DynamicPowerAndToughness]
      def graveyard_abilities = [ReturnFromGraveyardAbility.new(source: self)]
    end
  end
end