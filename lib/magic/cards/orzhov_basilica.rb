module Magic
  module Cards
    OrzhovBasilica = Card("Orzhov Basilica") do
      type "Land"
      enters_tapped
    end

    class OrzhovBasilica < Card
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
        def mana_produced
          { white: 1, black: 1 }
        end
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ManaAbility]
    end
  end
end