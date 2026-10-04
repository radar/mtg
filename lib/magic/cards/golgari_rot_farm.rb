module Magic
  module Cards
    GolgariRotFarm = Card("Golgari Rot Farm") do
      type "Land"
      enters_tapped
    end

    class GolgariRotFarm < Card
      class ReturnLandChoice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.lands
          super
        end

        def resolve!(target:)
          target.return_to_hand
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ReturnLandChoice.new(actor: actor))
        end
      end

      class ManaAbility < Magic::TapManaAbility
        # A single fixed option, so `ManaAbility#resolve!` auto-selects it.
        def choices = [:both]

        def mana_produced
          { black: 1, green: 1 }
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ManaAbility]
    end
  end
end
