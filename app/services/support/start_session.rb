# frozen_string_literal: true

module Support
  class StartSession
    Result = Struct.new(:payload, :error, :status, keyword_init: true) do
      def ok?
        error.nil?
      end
    end

    def initialize(actor:, user_id:, reason:)
      @actor = actor
      @user_id = user_id
      @reason = reason.to_s
    end

    def call
      return failure(:impersonation_reason_invalid, :unprocessable_content) unless reason_valid?
      return failure(:impersonation_target_invalid, :unprocessable_content) unless target_allowed?

      session = nil
      token = nil
      actor.with_lock do
        return busy if SupportSession.open_for(actor)

        session = build_session
        token = issue_token(session)
      end
      notify(session)
      Result.new(payload: payload(session, token))
    end

    private

    attr_reader :actor, :user_id, :reason

    def reason_valid?
      reason.length.between?(10, 500)
    end

    def target
      return @target if defined?(@target)

      @target = User.find_by(id: user_id)
    end

    def target_allowed?
      target.present? && target.organization_id.present? && target.id != actor.id && target.role&.name != 'SUPER_ADMIN'
    end

    def busy
      Result.new(error: :impersonation_in_progress, status: :conflict)
    end

    def failure(code, status)
      Result.new(error: code, status:)
    end

    def build_session
      now = Time.current
      SupportSession.create!(
        actor:,
        user: target,
        organization: target.organization,
        reason:,
        jti: SecureRandom.uuid,
        started_at: now,
        expires_at: now + SupportSession::DURATION
      )
    end

    def issue_token(session)
      payload = Warden::JWTAuth::PayloadUserHelper.payload_for_user(target, :user)
      payload['exp'] = session.expires_at.to_i
      payload['impersonation'] = true
      payload['impersonator_id'] = actor.id
      payload['support_session_id'] = session.id
      token = Warden::JWTAuth::TokenEncoder.new.call(payload)
      target.allowlisted_jwts.create!(jti: payload['jti'], aud: payload['aud'], exp: session.expires_at)
      session.update!(jti: payload['jti'])
      token
    end

    def notify(session)
      recipients = [target] + session.organization.users.joins(:role).where(roles: { name: 'ADMIN' }).to_a
      recipients.uniq.each do |recipient|
        SupportSessionMailer.with(session:, recipient:).started.deliver_later(queue: :mailers)
      end
    end

    def payload(session, token)
      {
        id: session.id,
        token:,
        expires_at: session.expires_at,
        user: {
          id: target.id,
          name: target.name,
          email: target.email,
          role: { id: target.role_id, name: target.role.name },
          organization_id: target.organization_id
        },
        organization: { id: target.organization_id, name: target.organization.name }
      }
    end
  end
end
