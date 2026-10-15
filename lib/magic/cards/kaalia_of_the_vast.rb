module Magic
  module Cards
    KaaliaOfTheVast = Creature("Kaalia of the Vast") do
      cost generic: 1, red: 1, white: 1, black: 1
      legendary_creature_type "Human Cleric"
      keywords :flying
      power 2
      toughness 2
    end

    class KaaliaOfTheVast < Creature
      # "Whenever Kaalia attacks an opponent, you may put an Angel, Demon, or Dragon creature card from your hand onto
      # the battlefield tapped and attacking that opponent."
      class PutChoice < Magic::Choice
        def initialize(actor:, defender:)
          super(actor: actor)
          @defender = defender
        end

        def choices
          controller.hand.select { |card| card.creature? && %w[Angel Demon Dragon].any? { |type| card.type?(type) } }
        end

        def upto = 1

        def may? = true

        def prompt = "Kaalia of the Vast: you may put an Angel, Demon, or Dragon creature card from your hand onto the battlefield tapped and attacking."

        def decline!
        end

        def resolve!(targets: [])
          targets = Array(targets).uniq
          invalid = targets - choices
          raise ArgumentError, "#{invalid.map(&:name).join(', ')} can't be put onto the battlefield" if invalid.any?
          raise ArgumentError, "can put at most 1 card onto the battlefield" if targets.size > 1

          targets.each do |card|
            permanent = Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: controller,
                                                       enters_tapped: true)
            game.current_turn.declare_attacker(permanent, target: @defender) if permanent.is_a?(Permanent)
          end
        end
      end

      class AttacksTrigger < TriggeredAbility
        def should_perform?
          event.attack.attacker == actor && event.attack.target.is_a?(Magic::Player)
        end

        def call
          choice = PutChoice.new(actor: actor, defender: event.attack.target)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::AttackDeclared => AttacksTrigger }
    end
  end
end
