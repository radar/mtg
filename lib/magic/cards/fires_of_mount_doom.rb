module Magic
  module Cards
    FiresOfMountDoom = Enchantment("Fires of Mount Doom") do
      cost generic: 2, red: 1
      type T::Super::Legendary, T::Enchantment
    end

    class FiresOfMountDoom < Enchantment
      # "When Fires of Mount Doom enters, it deals 2 damage to target creature an opponent controls. Destroy all
      # Equipment attached to that creature."
      class DamageChoice < Magic::Choice::Targeted
        def choices = battlefield.creatures.select { _1.controller != controller }

        def choice_amount = 1

        def resolve!(target:)
          deal_damage 2, to: target
          target.attachments.select { _1.card.is_a?(Cards::Equipment) }.each(&:destroy!)
        end

        # The target is mandatory: declining picks a legal creature.
        def decline! = resolve!(target: choices.first)
      end

      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform? = event.permanent == actor

        def call
          choice = DamageChoice.new(actor: actor)
          game.add_choice(choice) if choice.choices.any?
        end
      end

      # "{2}{R}: Exile the top card of your library. You may play that card this turn."
      class ExileAbility < Magic::ActivatedAbility
        def costs = [Costs::Mana.new(generic: 2, red: 1)]

        def resolve!
          top = controller.library.first
          return unless top

          top.exile!
          game.play_permissions.grant_until_end_of_turn(card: top, player: controller)
          watcher = PlayedWatcher.new(top, false)
          [Events::SpellCast, Events::EnteredTheBattlefield].each do |event_class|
            game.add_delayed_trigger(source: source, event_class: event_class, trigger_class: watcher)
          end
        end
      end

      # "When you play a card this way, Fires of Mount Doom deals 2 damage to each player." A delayed triggered ability
      # (CR 603.7a) made when the exile ability resolves, so it outlives Fires. The watcher stands in for the trigger
      # class and remembers the exiled card; it fires once (a cast spell also enters the battlefield).
      class PlayedTrigger < TriggeredAbility
        def initialize(event:, actor:, watcher:)
          super(event: event, actor: actor)
          @watcher = watcher
        end

        def should_perform?
          return false if @watcher.fired

          card = event.is_a?(Events::SpellCast) ? event.spell : event.permanent.card
          player = event.is_a?(Events::SpellCast) ? event.player : event.permanent.controller
          return false unless card == @watcher.card && player == controller

          @watcher.fired = true
        end

        def call
          game.players.each { deal_damage 2, to: _1 }
        end
      end

      PlayedWatcher = Struct.new(:card, :fired) do
        def new(actor:, event:) = PlayedTrigger.new(actor: actor, event: event, watcher: self)
      end

      def etb_triggers = [EntersTrigger]

      def activated_abilities = [ExileAbility]
    end
  end
end
