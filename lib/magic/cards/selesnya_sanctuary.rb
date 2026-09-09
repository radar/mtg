module Magic
  module Cards
    SelesnyaSanctuary = Card("Selesnya Sanctuary") do
      type "Land"
      enters_tapped

      enters_the_battlefield do
        game.add_choice(SelesnyaSanctuary::ReturnLandChoice.new(actor: actor))
      end
    end

    class SelesnyaSanctuary < Card
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

      class ManaAbility < Magic::TapManaAbility
        def mana_produced
          { green: 1, white: 1 }
        end
      end

      def activated_abilities = [ManaAbility]
    end
  end
end