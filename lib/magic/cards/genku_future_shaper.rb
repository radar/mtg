module Magic
  module Cards
    GenkuFutureShaper = Creature("Genku, Future Shaper") do
      cost "{2}{W}{U}"
      legendary_creature_type "Moonfolk Wizard"
      power 2
      toughness 5
    end

    class GenkuFutureShaper < Creature
      FoxToken = Token.create("Fox") do
        creature_type "Fox"
        power 2
        toughness 2
        colors :white
        keywords :vigilance
      end

      MoonfolkToken = Token.create("Moonfolk") do
        creature_type "Moonfolk"
        power 1
        toughness 2
        colors :blue
        keywords :flying
      end

      RatToken = Token.create("Rat") do
        creature_type "Rat"
        power 1
        toughness 1
        colors :black
        keywords :lifelink
      end

      # "Choose one that hasn't been chosen this turn." Answer with `resolve_choice!(mode: :fox | :moonfolk | :rat)`.
      class TokenChoice < Magic::Choice
        TOKENS = { fox: FoxToken, moonfolk: MoonfolkToken, rat: RatToken }.freeze

        def choices
          TOKENS.keys.reject { |mode| actor.mode_chosen_this_turn?(mode) }
        end

        def prompt = "Choose a creature token to create."

        def resolve!(mode:)
          raise "Invalid or already-chosen mode for Genku" unless choices.include?(mode)

          actor.choose_mode_this_turn!(mode)
          create_token(token: TOKENS.fetch(mode))
        end
      end

      # "Whenever another nontoken permanent you control leaves the battlefield, choose one that hasn't been chosen this
      # turn. Create a creature token with those characteristics."
      class LeavesTrigger < TriggeredAbility
        def should_perform?
          event.permanent != actor && !event.permanent.token? && event.permanent.controller == controller
        end

        def call
          choice = TokenChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      # "{3}{W}{U}: Put a +1/+1 counter on each creature you control."
      class CountersAbility < Magic::ActivatedAbility
        costs "{3}{W}{U}"

        def resolve!
          controller.creatures.each { |creature| add_counter("+1/+1", to: creature) }
        end
      end

      def activated_abilities = [CountersAbility]
      def event_handlers = super.merge({ Events::LeftTheBattlefield => LeavesTrigger }) { |_, old, new| [*old, *new] }
    end
  end
end
