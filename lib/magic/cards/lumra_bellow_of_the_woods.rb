module Magic
  module Cards
    LumraBellowOfTheWoods = Creature("Lumra, Bellow of the Woods") do
      legendary_creature_type "Elemental Bear"
      cost generic: 4, green: 2
      keywords :reach, :vigilance
      power 0
      toughness 0
    end

    class LumraBellowOfTheWoods < Creature
      # Lumra's power and toughness are each equal to the number of lands you control.
      class LandCount < Abilities::Static::CharacteristicSetting
        def applicable_targets = [source]

        def set_base_power = controller.lands.count

        def set_base_toughness = controller.lands.count
      end

      def static_abilities = [LandCount]

      # When Lumra enters, mill four cards. Then return all land cards from your graveyard to the battlefield
      # tapped.
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.mill(4)
          [*controller.graveyard.cards].select(&:land?).each do |land|
            Permanent.resolve(card: land, game: game, from_zone: land.zone, cast: false, controller: controller, enters_tapped: true)
          end
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
