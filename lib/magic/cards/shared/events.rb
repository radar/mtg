module Magic
  module Cards
    module Shared
      module Events
        def event_handlers
          @event_handlers ||= {}
        end

        def add_event_handler(event, &block)
          event_handlers[event] ||= []
          event_handlers[event] = block
        end

        def trigger_effect(effect, source: self, **args)
          case effect
          when :add_counter
            if args[:target].is_a?(Player)
              game.add_effect(Effects::AddCounterToPlayer.new(source: source, player: args[:target], **args))
            else
              game.add_effect(Effects::AddCounterToPermanent.new(source: source, **args))
            end
          when :deal_combat_damage
            game.add_effect(Effects::DealCombatDamage.new(source: source, **args))
          when :counter_spell
            game.add_effect(Effects::CounterSpell.new(source: source, **args))
          when :deal_damage
            game.add_effect(Effects::DealDamage.new(source: source, **args))
          when :destroy_target
            game.add_effect(Effects::DestroyTarget.new(source: source, **args))
          when :draw_cards
            game.add_effect(Effects::DrawCards.new(source: source, **args))
          when :exile
            if args[:target].is_a?(Permanent)
              game.add_effect(Effects::ExilePermanent.new(source: source, **args))
            else
              game.add_effect(Effects::ExileCard.new(source: source, **args))
            end
          when :gain_life
            game.add_effect(Effects::GainLife.new(source: source, target: source.controller, **args))
          when :grant_keyword
            game.add_effect(Effects::GrantKeyword.new(source: source, **args))
          when :lose_game
            game.add_effect(Effects::LoseGame.new(source: source, **args))
          when :lose_life
            game.add_effect(Effects::LoseLife.new(source: source, **args))
          when :modify_power_toughness
            game.add_effect(Effects::ApplyPowerToughnessModification.new(source: source, **args))
          when :move_card_zone
            game.add_effect(Effects::MoveCardZone.new(source: source, **args))
          when :move_permanent_zone
            game.add_effect(Effects::MovePermanentZone.new(source: source, **args))
          when :phase_out
            game.add_effect(Effects::PhaseOut.new(source: source, **args))
          when :return_target_from_graveyard_to_battlefield
            game.add_effect(Effects::ReturnTargetFromGraveyardToBattlefield.new(source: source, **args))
          when :return_to_owners_hand
            game.add_effect(Effects::ReturnToOwnersHand.new(source: source, **args))
          when :sacrifice
            game.add_effect(Effects::Sacrifice.new(source: source, **args))
          when :tap
            game.add_effect(Effects::Tap.new(source: source, **args))
          else
            raise "Unknown trigger: #{effect.inspect}"
          end
        end
      end
    end
  end
end
