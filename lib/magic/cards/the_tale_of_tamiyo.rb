module Magic
  module Cards
    TheTaleOfTamiyo = Saga("The Tale of Tamiyo") do
      type T::Super::Legendary, T::Enchantment, "Saga"
      cost generic: 2, blue: 1
    end

    class TheTaleOfTamiyo < Saga
      CARD_TYPES = Zones::Graveyard::TYPE_PREDICATES

      # I, II, III -- Mill two cards. If two cards that share a card type were milled this way, draw a card and repeat this
      # process.
      class MillChapter < Saga::ChapterAbility
        def resolve!
          loop do
            milled = controller.mill(2).to_a
            break unless milled.size == 2 && share_a_card_type?(*milled)

            trigger_effect(:draw_card)
          end
        end

        private

        def share_a_card_type?(first, second)
          CARD_TYPES.any? { |predicate| first.public_send(predicate) && second.public_send(predicate) }
        end
      end

      # IV -- Exile any number of target instant, sorcery, and/or Tamiyo planeswalker cards from your graveyard. Copy them.
      # You may cast any number of the copies.
      class ExileChoice < Magic::Choice::Targeted
        def choices
          controller.graveyard.cards.select { _1.instant? || _1.sorcery? || (_1.planeswalker? && _1.name.include?("Tamiyo")) }
        end

        def choice_amount = 0..choices.size

        def resolve!(targets:)
          raise ArgumentError, "choose cards that are in your graveyard" unless (targets - choices).empty?

          targets.each do |card|
            card.exile!
            game.add_choice(Magic::Choice::MayCastCopy.new(actor: actor, card: card))
          end
        end
      end

      class ExileChapter < Saga::ChapterAbility
        def resolve!
          choice = ExileChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def chapters = [MillChapter, MillChapter, MillChapter, ExileChapter]
    end
  end
end
