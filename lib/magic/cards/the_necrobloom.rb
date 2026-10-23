module Magic
  module Cards
    TheNecrobloom = Creature("The Necrobloom") do
      legendary_creature_type "Plant"
      cost "{1}{W}{B}{G}"
      power 2
      toughness 7
    end

    class TheNecrobloom < Creature
      # "Landfall -- Whenever a land you control enters, create a 0/1 green Plant creature token. If you control seven or
      # more lands with different names, create a 2/2 black Zombie creature token instead."
      class LandfallTrigger < TriggeredAbility::Landfall
        PlantToken = Token.create "Plant" do
          creature_type "Plant"
          power 0
          toughness 1
          colors :green
        end

        ZombieToken = Token.create "Zombie" do
          creature_type "Zombie"
          power 2
          toughness 2
          colors :black
        end

        def should_perform? = event.player == controller

        def call
          if controller.lands.map(&:name).uniq.count >= 7
            create_token(token: ZombieToken)
          else
            create_token(token: PlantToken)
          end
        end
      end

      # "Land cards in your graveyard have dredge 2." Dredged with `Player#dredge!` in place of a draw.
      class LandDredge < StaticAbility
        def dredge_amount(card, player)
          2 if player == controller && card.land?
        end
      end

      def static_abilities = [LandDredge]

      def event_handlers = { Events::Landfall => LandfallTrigger }
    end
  end
end
