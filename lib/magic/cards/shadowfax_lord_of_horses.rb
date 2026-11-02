module Magic
  module Cards
    ShadowfaxLordOfHorses = Creature("Shadowfax, Lord of Horses") do
      cost "{3}{R}{W}"
      legendary_creature_type "Horse"
      power 4
      toughness 4
    end

    class ShadowfaxLordOfHorses < Creature
      # "Horses you control have haste." Shadowfax is a Horse himself.
      class HorsesHaste < Abilities::Static::KeywordGrant
        keyword_grants Keywords::HASTE
        applicable_targets { source.controller.creatures.select { _1.type?("Horse") } }
      end

      def static_abilities = [HorsesHaste]

      # "Whenever Shadowfax attacks, you may put a creature card with lesser power from your hand onto the battlefield
      # tapped and attacking."
      class PutChoice < Magic::Choice
        def initialize(actor:, defender:)
          super(actor: actor)
          @defender = defender
        end

        def choices
          controller.hand.select { |card| card.creature? && card.base_power.to_i < actor.power }
        end

        def upto = 1

        def may? = true

        def prompt = "Put a creature card with power less than #{actor.power} from your hand onto the battlefield tapped and attacking?"

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
          event.attack.attacker == actor
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
