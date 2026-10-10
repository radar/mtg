module Magic
  module Cards
    AdelineResplendentCathar = Creature("Adeline, Resplendent Cathar") do
      cost generic: 1, white: 2
      legendary_creature_type "Human Knight"
      keywords :vigilance
      power 0
      toughness 4
    end

    class AdelineResplendentCathar < Creature
      HumanToken = Token.create "Human" do
        creature_type "Human"
        power 1
        toughness 1
        colors :white
      end

      # "Adeline's power is equal to the number of creatures you control." (A power of 0 plus one for each.)
      class PowerFromCreatures < Abilities::Static::PowerAndToughnessModification
        def applicable_targets = [source]

        def power_modification = source.controller.creatures.count
        def toughness_modification = 0
      end

      # "...that's tapped and attacking that player or a planeswalker they control." The player and each of their
      # planeswalkers are the options; with no planeswalker, the lone option is chosen for you.
      class AttackTargetChoice < Magic::Choice::Targeted
        def initialize(actor:, opponent:)
          @opponent = opponent
          super(actor: actor)
        end

        def prompt = "Choose which player or planeswalker the tapped and attacking Human token attacks."

        def targets? = false

        def choice_amount = 1

        def choices = [@opponent, *@opponent.permanents.select(&:planeswalker?)]

        def resolve!(target:)
          trigger_effect(:create_token, token_class: HumanToken, amount: 1, enters_tapped: true, attacking: true, attack_target: target)
        end
      end

      # "Whenever you attack, for each opponent, create a 1/1 white Human creature token that's tapped and attacking
      # that player or a planeswalker they control."
      class AttackTrigger < TriggeredAbility
        def should_perform?
          event.active_player == controller && event.attacks.any?
        end

        def call
          opponents.each { |opponent| game.add_choice(AttackTargetChoice.new(actor: actor, opponent: opponent)) }
        end
      end

      def static_abilities = [PowerFromCreatures]
      def event_handlers = { Events::FinalAttackersDeclared => AttackTrigger }
    end
  end
end
