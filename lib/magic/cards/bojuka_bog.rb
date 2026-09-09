module Magic
  module Cards
    BojukaBog = Card("Bojuka Bog") do
      type "Land"
      enters_tapped

      enters_the_battlefield do
        game.add_choice(Choice.new(actor: actor))
      end
    end

    class BojukaBog < Card
      class Choice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.game.players
          super
        end

        def resolve!(target:)
          target.graveyard.cards.each(&:exile!)
        end
      end

      class ManaAbility < Magic::TapManaAbility
        choices :black
      end

      def activated_abilities = [ManaAbility]
    end
  end
end