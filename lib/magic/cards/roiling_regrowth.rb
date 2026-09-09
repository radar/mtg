module Magic
  module Cards
    class RoilingRegrowth < Instant
      card_name "Roiling Regrowth"
      cost generic: 2, green: 1

      def additional_costs = [Costs::Sacrifice.new(self, controller.lands)]

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, upto: 2, to_zone: :battlefield, enters_tapped: true, filter: Filter[:basic_lands])
        end
      end

      def resolve! = game.add_choice(Choice.new(actor: self))
    end
  end
end