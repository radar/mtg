module Magic
  module Cards
    ManifoldMouse = Creature("Manifold Mouse") do
      cost generic: 1, red: 1
      creature_type("Mouse Soldier")
      power 1
      toughness 2
      offspring generic: 2
    end

    class ManifoldMouse < Creature
      # At the beginning of combat on your turn, target Mouse you control gains your choice of double strike or
      # trample until end of turn.
      class CombatTrigger < TriggeredAbility
        class KeywordChoice < Magic::Choice
          KEYWORDS = %i[double_strike trample].freeze

          def initialize(actor:, mouse:)
            @mouse = mouse
            super(actor: actor)
          end

          def choices = KEYWORDS

          def resolve!(keyword:)
            raise ArgumentError, "choose double_strike or trample" unless choices.include?(keyword)

            trigger_effect(:grant_keyword, target: @mouse, keyword: keyword)
          end
        end

        class MouseChoice < Magic::Choice::Targeted
          def choices = battlefield.controlled_by(controller).creatures.select { _1.type?("Mouse") }

          def choice_amount = 1

          def resolve!(target:)
            game.choices.add(KeywordChoice.new(actor: actor, mouse: target))
          end
        end

        def should_perform? = controllers_turn?

        def call
          choice = MouseChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::BeginningOfCombat => CombatTrigger)
    end
  end
end
