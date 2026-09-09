module Magic
  module Cards
    class CropRotation < Instant
      card_name "Crop Rotation"
      cost green: 1

      def additional_costs
        [Costs::Sacrifice.new(self, controller.lands)]
      end

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, to_zone: :battlefield, filter: Filter[:lands])
        end
      end

      def resolve!
        game.add_choice(Choice.new(actor: self))
      end
    end
  end
end