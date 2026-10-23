module Magic
  class Choice
    # Populate (rule 701.36): "create a token that's a copy of a creature token you control." The token is chosen, not
    # targeted. With one creature token it is picked automatically; with none, nothing happens (callers add the choice
    # only when `any?` is true, or use `Choice::Populate.add(game:, actor:)`).
    class Populate < Targeted
      def self.add(game:, actor:)
        choice = new(actor: actor)
        game.add_choice(choice) if choice.choices.any?
      end

      def prompt = "Choose a creature token you control to copy."

      def targets? = false

      def choices = controller.creatures.select(&:token?)

      def choice_amount = 1

      def resolve!(target:)
        Permanent.token_copy(game: game, owner: controller, card: target.copiable_card)
      end
    end
  end
end
