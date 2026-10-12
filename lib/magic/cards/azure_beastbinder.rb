module Magic
  module Cards
    AzureBeastbinder = Creature("Azure Beastbinder") do
      cost generic: 1, blue: 1
      creature_type("Rat Rogue")
      keywords :vigilance
      power 1
      toughness 3
    end

    class AzureBeastbinder < Creature
      # This creature can't be blocked by creatures with power 2 or greater.
      def can_be_blocked?(blocker) = blocker.power < 2

      # A game-level listener that ends the effect at the beginning of the binder's controller's next turn.
      class WearOff
        def initialize(game:, permanent:, player:, modifiers:)
          @game = game
          @permanent = permanent
          @player = player
          @modifiers = modifiers
        end

        def receive_event(event)
          return unless event.is_a?(Events::BeginningOfUpkeep) && event.player == @player

          @game.unsubscribe(self)
          @permanent.modifiers.delete_if { |modifier| @modifiers.include?(modifier) }
          @permanent.restore_abilities!
        end
      end

      # Whenever this creature attacks, up to one target artifact, creature, or planeswalker an opponent controls
      # loses all abilities until your next turn. If it's a creature, it also has base power and toughness 2/2
      # until your next turn.
      class AttacksTrigger < TriggeredAbility
        class BindChoice < Magic::Choice::Targeted
          def choices = battlefield.not_controlled_by(controller).by_any_type("Artifact", "Creature", "Planeswalker")

          def choice_amount = 0..1

          def resolve!(target:)
            modifiers = []
            if target.creature?
              before = target.modifiers.dup
              target.modify_base_power(2, until_eot: false)
              target.modify_base_toughness(2, until_eot: false)
              modifiers = target.modifiers - before
            end
            target.lose_all_abilities!
            game.subscribe(WearOff.new(game: game, permanent: target, player: controller, modifiers: modifiers))
          end
        end

        def should_perform? = event.attacks.any? { _1.attacker == actor }

        def call
          choice = BindChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      def event_handlers = super.merge(Events::FinalAttackersDeclared => AttacksTrigger)
    end
  end
end
