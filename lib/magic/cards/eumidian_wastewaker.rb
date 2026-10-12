module Magic
  module Cards
    EumidianWastewaker = Creature("Eumidian Wastewaker") do
      cost generic: 2, black: 2
      creature_type "Insect Cleric"
      power 3
      toughness 3
    end

    class EumidianWastewaker < Creature
      # "...you and defending player each discard a card or sacrifice a permanent. You draw a card for each land card
      # put into a graveyard this way." One choice per player; `target` is a card in hand or a permanent they control.
      class DiscardOrSacrificeChoice < Magic::Choice
        attr_reader :player

        def chooser = player

        def initialize(actor:, player:)
          super(actor: actor)
          @player = player
        end

        def prompt = "Discard a card or sacrifice a permanent."

        def choices
          [*player.hand.to_a, *player.permanents.to_a]
        end

        def resolve!(target:)
          land = target.is_a?(Permanent) ? target.card.land? : target.land?
          target.is_a?(Permanent) ? target.sacrifice! : target.discard!
          trigger_effect(:draw_cards, number_to_draw: 1) if land
        end
      end

      class EndStepSacrifice < TriggeredAbility
        def call
          actor.sacrifice!
        end
      end

      # Encore {6}{B}{B}: "For each opponent, create a token copy that attacks that opponent this turn if able. They gain
      # haste. Sacrifice them at the beginning of the next end step."
      class EncoreAbility < Magic::ActivatedAbility
        costs "{6}{B}{B}, Exile {this}"

        activate_from_graveyard_as_sorcery

        def resolve!
          game.opponents(controller).each do |_opponent|
            [*trigger_effect(:create_token_copy, card: source)].each do |token|
              token.grant_haste!
              token.must_attack_this_turn!
              token.register_turn_trigger(Events::BeginningOfEndStep, EndStepSacrifice)
            end
          end
        end
      end

      def graveyard_abilities = [EncoreAbility.new(source: self)]

      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.attacks.any? { |attack| attack.attacker == actor }
        end

        def call
          defending = event.attacks.find { |attack| attack.attacker == actor }.target
          # Choices are answered most-recently-added first, and the active player chooses first.
          [defending, controller].select { |player| player.is_a?(Player) }.each do |player|
            choice = DiscardOrSacrificeChoice.new(actor: actor, player: player)
            game.add_choice(choice) if choice.choices.any?
          end
        end
      end

      def event_handlers
        { Events::FinalAttackersDeclared => AttackTrigger }
      end
    end
  end
end
