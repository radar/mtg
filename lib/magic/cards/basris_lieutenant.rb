module Magic
  module Cards
    BasrisLieutenant = Creature("Basri's Lieutenant") do
      creature_type "Human Knight"
      cost generic: 3, white: 1
      power 3
      toughness 4
      keywords :vigilance
      protections [Protection.new(condition: -> (card) { card.multi_colored? })]

      enters_the_battlefield do
        game.add_choice(BasrisLieutenant::Choice.new(actor: actor))
      end
    end

    class BasrisLieutenant < Creature
      KnightToken = Token.create "Knight" do
        creature_type "Knight"
        power 2
        toughness 2
        colors :white
        keywords :vigilance
      end

      class Choice < Magic::Choice::Targeted
        def choices
          creatures_you_control
        end

        def choice_amount
          1
        end

        def resolve!(target:)
          actor.trigger_effect(:add_counter, counter_type: Counters::Plus1Plus1, target: target)
        end
      end

      # Whenever this creature or another creature you control dies, ...
      class CreatureDiedTrigger < TriggeredAbility
        def should_perform?
          event.controller == actor.controller &&
            event.permanent.counters.of_type(Counters::Plus1Plus1).any?
        end

        def call
          actor.trigger_effect(:create_token, token_class: KnightToken)
        end
      end


      def event_handlers
        {
          Events::CreatureDied => CreatureDiedTrigger
        }
      end
    end
  end
end
