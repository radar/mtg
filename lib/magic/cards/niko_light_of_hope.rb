module Magic
  module Cards
    NikoLightOfHope = Creature("Niko, Light of Hope") do
      cost generic: 2, white: 1, blue: 1
      legendary_creature_type "Human Wizard"
      power 3
      toughness 4
    end

    class NikoLightOfHope < Creature
      # "When Niko enters, create two Shard tokens."
      class EntersTrigger < TriggeredAbility::EnterTheBattlefield
        def should_perform?
          event.permanent == actor
        end

        def call
          create_token(token:Tokens::Shard, amount: 2)
        end
      end

      # "Return it to the battlefield under its owner's control at the beginning of the next end step", and the Shards stop
      # being copies then too. The pairs wait on Niko (`state[:niko_pending]`).
      class EndStepTrigger < TriggeredAbility
        def should_perform? = actor.state[:niko_pending].to_a.any?

        def call
          pending, actor.state[:niko_pending] = actor.state[:niko_pending], []
          pending.each do |entry|
            entry[:shards].each do |shard|
              shard.copied_card = nil
              shard.apply_continuous_effects!
            end
            card = entry[:card]
            Permanent.put_onto_battlefield(game: game, card: card, from_zone: card.zone, controller: card.owner) if card.zone&.exile?
          end
        end
      end

      # "{2}, {T}: Exile target nonlegendary creature you control. Shards you control become copies of it until the next end
      # step. Return it to the battlefield under its owner's control at the beginning of the next end step."
      class ExileAbility < Magic::ActivatedAbility
        costs "{2}, {T}"

        def target_choices
          creatures_you_control.reject(&:legendary?)
        end

        def resolve!(target:)
          copiable = target.copiable_card
          card = target.card
          game.add_effect(Effects::ExilePermanent.new(source: source, target: target))
          shards = controller.permanents.select { _1.name == "Shard" }
          shards.each do |shard|
            shard.copied_card = copiable
            shard.apply_continuous_effects!
          end
          (source.state[:niko_pending] ||= []) << { card: card, shards: shards }
          game.add_delayed_trigger(source: source, event_class: Events::BeginningOfEndStep, trigger_class: EndStepTrigger)
        end
      end

      def etb_triggers = [EntersTrigger]
      def activated_abilities = [ExileAbility]
    end
  end
end
