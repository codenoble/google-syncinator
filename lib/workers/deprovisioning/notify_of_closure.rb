module Workers
  module Deprovisioning
    # Sends an email to the associated university email notifying the owner that
    #   the account is scheduled to be closed
    class NotifyOfClosure < Base
      include Sidekiq::Worker

      # Sends an email to the associated university email notifying the owner
      #   that the account is scheduled to be closed
      # @param deprovision_schedule_id [Integer] ID of the notify_of_closure
      #   DeprovisionSchedule to be completed
      # @return [nil]
      def perform(deprovision_schedule_id)
        schedule = find_schedule(deprovision_schedule_id)
        email = schedule.university_email

        unless schedule.canceled?
          # Only send a notice to the primary email to avoid duplicate emails
          Emails::NotifyOfClosure.new(schedule).send! if email.primary?
          schedule.update completed_at: DateTime.now if !Settings.dry_run?
          Log.info "Marked notify_of_closure schedule for #{email} complete"
        end

        nil
      end
    end
  end
end