module Api
  module Web
    class PasswordController < ::Api::Web::BaseController
      before_action :authenticate!

      def change
        result = ::Password::Change.call(
          password: params[:password],
          password_confirmation: params[:password_confirmation],
          current_password: params[:current_password],
          current_user: pundit_user)
        if result.failure?
          respond_fail(errors: result.errors)
        else
          respond_success
        end
      end
    end
  end
end
