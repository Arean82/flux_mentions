module Patch
  module WikiControllerPatch
    def self.included(base)
      base.class_eval do
        before_action :send_mail_if_mentions, only: [:create, :update]

        def send_mail_if_mentions
          return unless params[:content] && User.current.logged?
          project = @project
          return unless project

          content = params[:content]['text'].to_s
          users = project.users.to_a.delete_if { |u| (u.type != 'User' || u.mail.blank?) }
          settings = Setting.plugin_flux_mentions || {}
          mention_symbol = settings['symbol'].presence || '@'
          escaped_sym = Regexp.escape(mention_symbol)
          
          mentioned_users = users.select do |u|
            pattern = /(?:^|\s)#{escaped_sym}#{Regexp.escape(u.login)}(?=[^\w]|$)/
            content =~ pattern
          end

          mentioned_users.each do |mentioned_user|
            if ActionMailer::Base.smtp_settings[:address].present?
              begin
                WikiMailer.wiki_notification(@wiki, content, mentioned_user).deliver_now
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
