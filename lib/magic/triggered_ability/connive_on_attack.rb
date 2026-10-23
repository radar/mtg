module Magic
  class TriggeredAbility
    # "Whenever this creature attacks, it connives." Wired by the `connive :attacks` card macro.
    class ConniveOnAttack < Connive
      def should_perform? = event.attacks.any? { _1.attacker == actor }
    end
  end
end
