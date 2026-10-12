module Magic
  module Cards
    class Attachment < Card
      # Rule 303.4f: an Aura resolving enters attached to its target, so its enters
      # triggers already see what it enchants.
      def resolve!(target: nil, **args)
        # Equipment returned to the battlefield (Grasp of Fate) enters unattached: it has nothing it must attach to.
        return super(**args) if target.nil?

        permanent = super(attach_to: target, **args)
        permanent.attach_to!(target) unless permanent.attached_to == target
        permanent
      end

      def keyword_grants
        []
      end

      def type_grants
        []
      end

      # "Equipped creature is all creature types."
      def grants_all_creature_types?
        false
      end

      # Bark of Doran: "it assigns combat damage equal to its toughness rather than its power".
      def assigns_toughness_damage?(_creature)
        false
      end

      def power_modification
        0
      end

      def toughness_modification
        0
      end

      def can_activate_ability?(_)
        true
      end

      # "Enchanted creature doesn't untap during its controller's untap step."
      def does_not_untap_during_untap_step?
        false
      end

      # "Enchanted creature can't become untapped."
      def prevents_untapping?
        false
      end

      # "Enchanted creature can't have counters put on it."
      def prevents_counters?
        false
      end
    end
  end
end
