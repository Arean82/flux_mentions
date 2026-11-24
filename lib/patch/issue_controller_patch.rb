module Patch
  module IssueControllerPatch
    def self.included(base)
      base.class_eval do
        after_create :send_mail

        def send_mail
          if self.journalized.is_a?(Issue)
            issue = self.journalized
            project = self.journalized.project
            return unless project

            settings = Setting.plugin_flux_mentions || {}
            return if settings['send_emails'] == '0' || settings['send_emails'] == false

            mention_symbol = settings['symbol'].presence || '@'
            escaped_sym = Regexp.escape(mention_symbol)
            group_enabled = settings['enable_group_mentions'] == '1' || settings['enable_group_mentions'] == true
            
            target_users_desc = Set.new
            target_users_notes = Set.new
            users = project.users.active.to_a.delete_if { |u| u.type != 'User' || u.mail.blank? }

            # Scan description for mentions
            if self.journalized.description.present?
              users.each do |u|
                pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(u.login)}(?=[^\w]|$)/
                target_users_desc << u if self.journalized.description =~ pattern
              end

              if group_enabled
                Group.all.each do |grp|
                  grp_ident = grp.lastname.presence || grp.name
                  pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(grp_ident)}(?=[^\w]|$)/
                  if self.journalized.description =~ pattern
                    grp.users.active.each do |gu|
                      target_users_desc << gu if gu.mail.present? && project.users.include?(gu)
                    end
                  end
                end
              end

              target_users_desc.each do |mentioned_user|
                next if mentioned_user.pref[:notify_mentions] == '0'

                if ActionMailer::Base.smtp_settings[:address].present?
                  begin
                    IssueMailer.new_issue_description(issue, self, mentioned_user).deliver_now
                  rescue Net::SMTPAuthenticationError => e
                    Rails.logger.error "SMTP Error: #{e.message}"
                  rescue => e
                    Rails.logger.error "Mention Mailer Error: #{e.message}"
                  end
                else
                  Rails.logger.info "SMTP settings not configured. Email not sent."
                end
              end
            end

            # Scan notes for mentions
            if self.notes.present?
              users.each do |u|
                pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(u.login)}(?=[^\w]|$)/
                target_users_notes << u if self.notes =~ pattern
              end

              if group_enabled
                Group.all.each do |grp|
                  grp_ident = grp.lastname.presence || grp.name
                  pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(grp_ident)}(?=[^\w]|$)/
                  if self.notes =~ pattern
                    grp.users.active.each do |gu|
                      target_users_notes << gu if gu.mail.present? && project.users.include?(gu)
                    end
                  end
                end
              end

              target_users_notes.each do |mentioned_user|
                next if mentioned_user.pref[:notify_mentions] == '0'

                if ActionMailer::Base.smtp_settings[:address].present?
                  begin
                    IssueMailer.notes_notification(issue, self, mentioned_user).deliver_now
                  rescue Net::SMTPAuthenticationError => e
                    Rails.logger.error "SMTP Error: #{e.message}"
                  rescue => e
                    Rails.logger.error "Mention Mailer Error: #{e.message}"
                  end
                else
                  Rails.logger.info "SMTP settings not configured. Email not sent."
                end
              end
            end
          end
        end
      end
    end
  end
end
