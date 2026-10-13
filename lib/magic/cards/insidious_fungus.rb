module Magic
  module Cards
    InsidiousFungus = Creature("Insidious Fungus") do
      cost green: 1
      creature_type "Fungus"
      power 1
      toughness 2
    end

    class InsidiousFungus < Creature
      class DestroyChoice < Magic::Choice::Targeted
        def initialize(actor:, type:)
          @type = type
          super(actor: actor)
        end

        def choices = battlefield.permanents.by_any_type(@type)

        def choice_amount = 1

        def resolve!(target:)
          destroy(target)
        end
      end

      class LandChoice < Magic::Choice::May
        def choices = controller.hand.select(&:land?)

        def resolve!(target:)
          target.resolve!(enters_tapped: true)
        end
      end

      class ModeChoice < Magic::Choice
        ARTIFACT = :artifact
        ENCHANTMENT = :enchantment
        DRAW = :draw

        def modes = {
          ARTIFACT => "Destroy target artifact",
          ENCHANTMENT => "Destroy target enchantment",
          DRAW => "Draw a card. Then you may put a land card from your hand onto the battlefield tapped"
        }

        def resolve!(mode:)
          case mode
          when ARTIFACT, ENCHANTMENT
            choice = DestroyChoice.new(actor: actor, type: mode == ARTIFACT ? "Artifact" : "Enchantment")
            game.add_choice(choice) if choice.choices.any?
          when DRAW
            draw_card
            choice = LandChoice.new(actor: actor)
            game.add_choice(choice) if choice.choices.any?
          else
            raise ArgumentError, "unknown mode #{mode.inspect}"
          end
        end
      end

      # {2}, Sacrifice this creature: Choose one --
      class SacrificeAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new("{2}"), Costs::SelfSacrifice.new(source)]

        def resolve!
          game.choices.add(ModeChoice.new(actor: source))
        end
      end

      def activated_abilities = [SacrificeAbility]
    end
  end
end
