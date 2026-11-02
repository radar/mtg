module Magic
  module Cards
    EowynLadyOfRohan = Creature("Éowyn, Lady of Rohan") do
      cost generic: 2, white: 1
      legendary_creature_type "Human Noble"
      power 2
      toughness 4
    end

    class EowynLadyOfRohan < Creature
      # "Equip abilities you activate cost {1} less to activate."
      class EquipDiscount < StaticAbility
        def activation_cost_reduction_for_targets(ability, _targets, player)
          player == controller && ability.respond_to?(:equip?) && ability.equip? ? 1 : 0
        end
      end

      def static_abilities = [EquipDiscount]

      # "...target creature gains your choice of first strike or vigilance until end of turn." Resolving the pick
      # (`resolve!(keyword:)`) grants it; declining (`game.skip_choice!`) takes the first option, first strike.
      class KeywordChoice < Magic::Choice
        KEYWORDS = %i[first_strike vigilance].freeze

        def initialize(actor:, creature:)
          super(actor: actor)
          @creature = creature
        end

        def prompt = "Choose first strike or vigilance for #{@creature.name}."

        def choices = KEYWORDS

        def resolve!(keyword:)
          raise ArgumentError, "choose first strike or vigilance" unless KEYWORDS.include?(keyword)

          give_keyword(@creature, keyword)
        end

        def decline! = resolve!(keyword: KEYWORDS.first)
      end

      # The target is mandatory (CR 603.3d). "If that creature is equipped, it gains first strike and vigilance ...
      # instead", checked on resolution.
      class CreatureChoice < Magic::Choice::Targeted
        def choices = game.battlefield.creatures

        def choice_amount = 1

        def resolve!(target:)
          if target.attachments.any? { _1.card.is_a?(Cards::Equipment) }
            KeywordChoice::KEYWORDS.each { give_keyword(target, _1) }
          else
            game.add_choice(KeywordChoice.new(actor: actor, creature: target))
          end
        end

        def decline!
          target = choices.first
          resolve!(target: target) if target
        end
      end

      # "At the beginning of combat on your turn, ..."
      class BeginningOfCombatTrigger < TriggeredAbility
        def should_perform? = event.active_player == controller

        def call
          choice = CreatureChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = { Events::BeginningOfCombat => BeginningOfCombatTrigger }
    end
  end
end
