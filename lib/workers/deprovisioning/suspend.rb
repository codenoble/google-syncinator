module Workers
  module Deprovisioning
    class Suspend < Base
      class TrogdirError < StandardError; end

      include Sidekiq::Worker

      def perform(deprovision_schedule_id)
        schedule = find_schedule(deprovision_schedule_id)
        email = schedule.university_email

        unless schedule.canceled?
          biola_id = TrogdirPerson.new(email.uuid).biola_id

          GoogleAccount.new(email.address).suspend!
          DeleteTrogdirEmail.perform_async(email.uuid, email.address)
          ExpireLegacyEmailTable.perform_async(biola_id, email.address)
          schedule.update completed_at: DateTime.now if !Settings.dry_run?
          Log.info "Marked suspend schedule for #{email} complete"
        end
      end
    end
  end
end
