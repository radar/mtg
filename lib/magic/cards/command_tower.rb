module Magic
  module Cards
    class CommandTower < Card
      card_name "Command Tower"
      type Types::Land

      class ManaAbility < Magic::TapManaAbility
        def choices
          controller.commander.color_identity
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end
