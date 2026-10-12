module Magic
  module Cards
    GollumRiddleMaster = Creature("Gollum, Riddle Master") do
      legendary_creature_type "Halfling Horror"
      cost generic: 1, black: 1
      power 3
      toughness 1
    end

    class GollumRiddleMaster < Creature
      # What Gollum remembers: the chosen quality (:odd / :even) and the modes already chosen.
      # Kept on the card so trigger code reaches it through `actor.card`.
      attr_accessor :chosen_parity, :chosen_modes

      class ParityChoice < Magic::Choice
        def prompt = "Choose odd or even."

        def choices = %i[odd even]

        def resolve!(parity:)
          raise ArgumentError, "choose :odd or :even" unless choices.include?(parity)

          actor.card.chosen_parity = parity
          actor.card.chosen_modes = []
        end
      end

      # "As Gollum enters, choose odd or even. (Zero is even.)"
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.add_choice(ParityChoice.new(actor: actor))
        end
      end

      # "choose one that hasn't been chosen"
      class ModeChoice < Magic::Choice
        MODES = %i[counter drain draw].freeze

        def choices = MODES - (actor.card.chosen_modes || [])

        def resolve!(mode:)
          raise ArgumentError, "mode already chosen or invalid" unless choices.include?(mode)

          actor.card.chosen_modes = [*actor.card.chosen_modes, mode]
          case mode
          when :counter
            trigger_effect(:add_counter, counter_type: "+1/+1", target: actor, amount: 1)
          when :drain
            game.opponents(controller).each { |opponent| trigger_effect(:lose_life, target: opponent, life: 2) }
            trigger_effect(:gain_life, target: controller, life: 2)
          when :draw
            trigger_effect(:draw_cards, number_to_draw: 1)
          end
        end
      end

      # "Whenever an opponent casts a spell with mana value of the chosen quality, choose one that hasn't been chosen"
      class SpellCastTrigger < TriggeredAbility::SpellCast
        def should_perform?
          parity = actor.card.chosen_parity
          return false if parity.nil? || event.player == controller

          spell.mana_value.even? == (parity == :even)
        end

        def call
          choice = ModeChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def etb_triggers = [EntersTrigger]

      def event_handlers
        super.merge({ Events::SpellCast => SpellCastTrigger }) { |_, old, new| [*old, *new] }
      end
    end
  end
end
