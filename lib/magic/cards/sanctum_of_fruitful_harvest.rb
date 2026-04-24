module Magic
  module Cards
    SanctumOfFruitfulHarvest = Enchantment("Sanctum of Fruitful Harvest") do
      type T::Super::Legendary, T::Enchantment, "Shrine"
      cost generic: 2, green: 1
    end

    class SanctumOfFruitfulHarvest < Enchantment
      class FirstMainPhaseTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller
        end

        def call
          game.choices.add(SanctumOfFruitfulHarvest::ColorChoice.new(actor: actor))
        end
      end

      class ColorChoice < Magic::Choice::Color
        def resolve!(color:)
          shrines = controller.permanents.by_type("Shrine").count
          controller.add_mana(color => shrines)
        end
      end

      def event_handlers
        {
          Events::FirstMainPhase => FirstMainPhaseTrigger
        }
      end
    end
  end
end
