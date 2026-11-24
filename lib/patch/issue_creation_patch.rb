module Patch
  module IssueCreationPatch
    def self.included(base)
      base.class_eval do
        after_create :send_mail_on_create
        
        def send_mail_on_create
          issue = self
          project = self.project
          return unless project

          settings = Setting.plugin_flux_mentions || {}
          return if settings['send_emails'] == '0' || settings['send_emails'] == false

          mention_symbol = settings['symbol'].presence || '@'
          escaped_sym = Regexp.escape(mention_symbol)
          group_enabled = settings['enable_group_mentions'] == '1' || settings['enable_group_mentions'] == true
          
          # Scan description for mentions
          if issue.description.present?
            target_users = Set.new
            users = project.users.active.to_a.delete_if { |u| u.type != 'User' || u.mail.blank? }

            users.each do |u|
              pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(u.login)}(?=[^\w]|$)/
              target_users << u if issue.description =~ pattern
            end

            if group_enabled
              Group.all.each do |grp|
                grp_ident = grp.lastname.presence || grp.name
                pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(grp_ident)}(?=[^\w]|$)/
                if issue.description =~ pattern
                  grp.users.active.each do |gu|
                    target_users << gu if gu.mail.present? && project.users.include?(gu)
                  end
                end
              end
            end

            target_users.each do |mentioned_user|
              # Check user notification preference (default true unless explicitly turned off)
              next if mentioned_user.pref[:notify_mentions] == '0'

              if ActionMailer::Base.smtp_settings[:address].present?
                begin
                  IssueMailer.new_issue_description(issue, nil, mentioned_user).deliver_now
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
