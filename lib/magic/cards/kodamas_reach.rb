module Magic
  module Cards
    class KodamasReach < Sorcery
      card_name "Kodama's Reach"
      cost generic: 2, green: 1

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, upto: 2, to_zone: :hand, filter: Filter[:basic_lands],
                prompt: "Search your library for up to two basic land cards. The first enters the battlefield tapped and the other goes into your hand.")
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