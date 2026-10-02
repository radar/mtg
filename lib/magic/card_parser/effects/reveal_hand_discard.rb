# frozen_string_literal: true

module Magic
  class CardParser
    module Effects
      # "Target opponent reveals their hand. You choose a noncreature, nonland card from it. That player
      # discards that card." (Duress, Pilfer). The hand is revealed, then the caster chooses
      # (`Choice::DiscardFromRevealedHand`, `game.resolve_choice!(card:)`); nothing is asked if no card
      # in the hand qualifies. Spans three sentences, so EffectList parses it as one effect.
      class RevealHandDiscard < Data.define(:excluded_types)
        include Effect

        LINE = /\ATarget opponent reveals their hand\. You choose an? (?:(?<filter>non[a-z]+(?:, non[a-z]+)*) )?card from it\. That player discards that card\.?\z/i

        def self.parse(text)
          return unless (m = LINE.match(text))

          new(excluded_types: m[:filter].to_s.split(", ").map { _1.downcase.delete_prefix("non").capitalize })
        end

        def target_choices = "game.opponents(controller)"

        def resolve_call
          <<~RUBY.chomp
            game.notify!(Events::CardsRevealed.new(player: target, cards: target.hand.cards.to_a))
            choice = Magic::Choice::DiscardFromRevealedHand.new(actor: #{Effect::THIS}, player: target, excluded_types: #{excluded_types.inspect})
            game.add_choice(choice) if choice.choices.any?
          RUBY
        end
      end
    end
  end
end
