module Magic
  module Cards
    class EnlightenedTutor < Instant
      card_name "Enlightened Tutor"
      cost white: 1

      class Choice < Magic::Choice
        attr_reader :choices

        def initialize(actor:)
          @choices = actor.controller.library.cards.by_any_type(T::Artifact, T::Enchantment)
          super
        end

        def resolve!(target:)
          controller.library.remove(target)
          controller.library.unshift(target)
          target.reveal! if target.respond_to?(:reveal!)
        end
      end

      def resolve!
        game.add_choice(Choice.new(actor: self))
      end
    end
  end
end