module Magic
  module Cards
    class IdyllicTutor < Sorcery
      card_name "Idyllic Tutor"
      cost generic: 2, white: 1

      class Choice < Magic::Choice::SearchLibrary
        def initialize(actor:)
          super(actor: actor, filter: Filter[:enchantments], reveal: true, to_zone: :hand)
        end
      end

      def resolve!
        game.add_choice(Choice.new(actor: self))
      end
    end
  end
end