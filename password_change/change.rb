module Password
  class Change < ::ApplicationInteractor
    delegate :current_user, to: :context
    delegate :password, :password_confirmation, :current_password, to: :context

    def call
      validate!
      current_user.password = password
      current_user.save!
    end

    private

    def validate!
      validator = ::PasswordValidator.new(
        password: password,
        password_confirmation: password_confirmation,
        current_password: current_password,
        user: current_user
      )
      context.fail!(errors: validator.errors.full_messages) if validator.invalid?
    end
  end
end


