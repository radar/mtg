module Magic
  module Cards
    class Necromentia < Sorcery
      card_name "Necromentia"
      cost generic: 1, black: 2

      BASIC_LAND_NAMES = %w[Plains Island Swamp Mountain Forest Wastes].flat_map { |name| [name, "Snow-Covered #{name}"] }.freeze

      ZombieToken = Token.create "Zombie" do
        creature_type "Zombie"
        power 2
        toughness 2
        colors :black
      end

      # "Choose a card name other than a basic land card name." Asked after the opponent is chosen, answered with
      # `resolve!(name:)`.
      class NameChoice < Magic::Choice
        attr_reader :opponent

        def initialize(actor:, opponent:)
          super(actor:)
          @opponent = opponent
        end

        def prompt = "Choose a card name other than a basic land card name"

        # "Search target opponent's graveyard, hand, and library for any number of cards with that name and exile
        # them. That player shuffles, then creates a 2/2 black Zombie creature token for each card exiled from
        # their hand this way." Takes every card with that name.
        def resolve!(name:)
          raise ArgumentError, "#{name} is a basic land card name" if BASIC_LAND_NAMES.include?(name)

          from_hand = opponent.hand.cards.select { |card| card.name == name }
          from_other = [*opponent.graveyard.cards, *opponent.library.cards].select { |card| card.name == name }
          [*from_hand, *from_other].each(&:exile!)
          opponent.shuffle!
          trigger_effect(:create_token, token_class: ZombieToken, controller: opponent, amount: from_hand.count) if from_hand.any?
        end
      end

      def target_choices = game.opponents(controller)

      def single_target? = true

      def resolve!(target:)
        game.add_choice(NameChoice.new(actor: self, opponent: target))
      end
    end
  end
end
