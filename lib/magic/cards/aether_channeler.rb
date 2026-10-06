module Magic
  module Cards
    AetherChanneler = Creature("Aether Channeler") do
      cost generic: 2, blue: 1
      creature_type "Human Wizard"
      power 2
      toughness 1
    end

    class AetherChanneler < Creature
      BirdToken = Token.create "Bird" do
        creature_type "Bird"
        power 1
        toughness 1
        colors :white
        keywords :flying
      end

      # "Return another target nonland permanent to its owner's hand."
      class BounceChoice < Magic::Choice::Targeted
        def choices = game.battlefield.permanents.nonland - [actor]
        def choice_amount = 1

        def resolve!(target:)
          trigger_effect(:return_to_owners_hand, target: target)
        end
      end

      class ModeChoice < Magic::Choice
        BIRD = :bird
        BOUNCE = :bounce
        DRAW = :draw

        def modes
          {
            BIRD => "Create a 1/1 white Bird creature token with flying",
            BOUNCE => "Return another target nonland permanent to its owner's hand",
            DRAW => "Draw a card",
          }
        end

        def resolve!(mode:)
          case mode
          when BIRD then actor.create_token(token_class: BirdToken)
          when BOUNCE
            choice = BounceChoice.new(actor: actor)
            game.choices.add(choice) if choice.choices.any?
          when DRAW then trigger_effect(:draw_card)
          else raise ArgumentError, "unknown mode #{mode.inspect}"
          end
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def call
          game.choices.add(ModeChoice.new(actor: actor))
        end
      end

      def etb_triggers = [EntersTrigger]
    end
  end
end
