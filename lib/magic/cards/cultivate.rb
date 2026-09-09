module Magic
  module Cards
    class Cultivate < Sorcery
      card_name "Cultivate"
      cost generic: 2, green: 1

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, upto: 2, to_zone: :hand, filter: Filter[:basic_lands])
        end

        def resolve!(targets:)
          targets.first&.resolve!(enters_tapped: true)
          targets.drop(1).each(&:move_to_hand!)
          controller.shuffle!
        end
      end

      def resolve!
        game.add_choice(Choice.new(actor: self))
      end
    end
  end
end