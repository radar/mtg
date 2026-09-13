module Magic
  module Cards
    Spelunking = Enchantment("Spelunking") do
      cost generic: 2, green: 1
    end

    class Spelunking < Enchantment
      class LandEntryChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          super
          @choices =hand.lands
        end

        def resolve!(target:)
          target.resolve!
          controller.gain_life(4) if target.any_type?("Cave")
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          controller.draw!
          game.add_choice(LandEntryChoice.new(actor: actor)) if controller.hand.lands.any?
        end
      end

      class LandsEnterUntapped < Abilities::Static::LandsEnterUntapped
        def lands_enter_untapped?(card)
          card.land? && card.controller == controller
        end
      end

      def etb_triggers = [EntersTrigger]

      def static_abilities = [LandsEnterUntapped]
    end
  end
end