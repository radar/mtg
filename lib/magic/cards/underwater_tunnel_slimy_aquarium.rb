module Magic
  module Cards
    class UnderwaterTunnelSlimyAquarium < Room
      class UnderwaterTunnel < Room::Door
        card_name "Underwater Tunnel"
        cost blue: 1

        # "When you unlock this door, surveil 2."
        when_unlocked do
          game.choices.add(Magic::Choice::Surveil.new(actor: actor, amount: 2))
        end
      end

      class SlimyAquarium < Room::Door
        card_name "Slimy Aquarium"
        cost generic: 3, blue: 1

        # Manifests dread, then puts a +1/+1 counter on that creature.
        class ManifestChoice < Magic::Choice::ManifestDread
          def manifested(permanent)
            trigger_effect(:add_counter, counter_type: "+1/+1", target: permanent)
          end
        end

        # "When you unlock this door, manifest dread, then put a +1/+1 counter on that creature."
        class UnlockedTrigger < Room::UnlockTrigger
          def call
            ManifestChoice.perform(actor: actor)
          end
        end

        def unlock_triggers = [UnlockedTrigger]
      end

      doors UnderwaterTunnel, SlimyAquarium
    end
  end
end
