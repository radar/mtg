module Magic
  module Cards
    SkyclaveApparition = Creature("Skyclave Apparition") do
      cost generic: 1, white: 2
      creature_type "Kor Spirit"
      power 2
      toughness 2
    end

    class SkyclaveApparition < Creature
      IllusionToken = Token.create "Illusion" do
        creature_type "Illusion"
        power 0
        toughness 0
        colors :blue
      end

      # "exile up to one target nonland, nontoken permanent you don't control with mana value 4 or less."
      class ExileChoice < Magic::Choice::Targeted
        def prompt = "Exile up to one nonland, nontoken permanent you don't control with mana value 4 or less."

        def choices
          game.opponents(controller).flat_map { |opponent| opponent.permanents.nonland }.reject(&:token?).select { _1.mana_value <= 4 }
        end

        def choice_amount = 1

        def resolve!(target:)
          card = target.card
          game.add_effect(Effects::ExilePermanent.new(source: actor, target: target))
          actor.exiled_cards << card
        end
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          choice = ExileChoice.new(actor: actor)
          game.choices.add(choice) if choice.choices.any?
        end
      end

      # "When this creature leaves the battlefield, the exiled card's owner creates an X/X blue Illusion creature
      # token, where X is the mana value of the exiled card."
      class LeavesTrigger < TriggeredAbility
        def call
          actor.exiled_cards.to_a.each do |card|
            trigger_effect(
              :create_token,
              token_class: IllusionToken,
              controller: card.owner,
              base_power: card.mana_value,
              base_toughness: card.mana_value,
            )
          end
        end
      end

      def etb_triggers = [EntersTrigger]
      def ltb_triggers = [LeavesTrigger]
    end
  end
end
