module Magic
  module Cards
    class DollmakersShopPorcelainGallery < Room
      ToyToken = Token.create "Toy" do
        type T::Artifact, T::Creature, T::Creatures["Toy"]
        power 1
        toughness 1
        colors :white
      end

      class DollmakersShop < Room::Door
        card_name "Dollmaker's Shop"
        cost generic: 1, white: 1

        # "Whenever one or more non-Toy creatures you control attack a player, create a 1/1 white Toy artifact creature
        # token." One token however many creatures attack.
        class AttacksTrigger < TriggeredAbility
          def should_perform?
            event.active_player == controller && event.attacks.any? do |attack|
              attack.attacker.controller == controller && !attack.attacker.type?("Toy") && attack.target.player?
            end
          end

          def call
            create_token(token:ToyToken)
          end
        end

        def event_handlers = { Events::FinalAttackersDeclared => AttacksTrigger }
      end

      class PorcelainGallery < Room::Door
        card_name "Porcelain Gallery"
        cost generic: 4, white: 2

        # "Creatures you control have base power and toughness each equal to the number of creatures you control."
        class BasePowerAndToughness < Abilities::Static::CharacteristicSetting
          applicable_targets { source.controller.creatures }

          def set_base_power(_permanent) = source.controller.creatures.count
          def set_base_toughness(_permanent) = source.controller.creatures.count
        end

        def static_abilities = [BasePowerAndToughness]
      end

      doors DollmakersShop, PorcelainGallery
    end
  end
end
