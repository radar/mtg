module Magic
  module Cards
    class ElspethSunsChampion < Planeswalker
      card_name "Elspeth, Sun's Champion"
      type T::Super::Legendary, T::Planeswalker, "Elspeth"
      cost "{4}{W}{W}"
      loyalty 4

      SoldierToken = Token.create("Soldier") do
        creature_type "Soldier"
        power 1
        toughness 1
        colors :white
      end

      # +1: Create three 1/1 white Soldier creature tokens.
      class LoyaltyAbility1 < Magic::LoyaltyAbility
        def loyalty_change = 1
        def description = "Create three 1/1 white Soldier creature tokens."

        def resolve!
          trigger_effect(:create_token, token_class: SoldierToken, amount: 3, controller: controller)
        end
      end

      # −3: Destroy all creatures with power 4 or greater.
      class LoyaltyAbility2 < Magic::LoyaltyAbility
        def loyalty_change = -3
        def description = "Destroy all creatures with power 4 or greater."

        def resolve!
          game.battlefield.creatures.select { |creature| creature.power >= 4 }.each do |creature|
            trigger_effect(:destroy_target, target: creature)
          end
        end
      end

      # −7: You get an emblem with "Creatures you control get +2/+2 and have flying."
      class Emblem < Magic::Emblem
        class PowerAndToughness < Abilities::Static::PowerAndToughnessModification
          def applicable_targets = source.controller.creatures

          def power_modification = 2
          def toughness_modification = 2
        end

        class Flying < Abilities::Static::KeywordGrant
          keyword_grants Keywords::FLYING
          applicable_targets { source.controller.creatures }
        end

        def static_abilities = [PowerAndToughness, Flying]
      end

      class LoyaltyAbility3 < Magic::LoyaltyAbility
        def loyalty_change = -7
        def description = "You get an emblem with \"Creatures you control get +2/+2 and have flying.\""

        def resolve!
          game.add_emblem(Emblem.new(game: game, owner: controller))
        end
      end

      def loyalty_abilities = [LoyaltyAbility1, LoyaltyAbility2, LoyaltyAbility3]
    end
  end
end
