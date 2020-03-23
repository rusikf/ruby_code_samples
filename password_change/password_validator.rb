class PasswordValidator < ::ApplicationValidator
  attr_accessor :password, :password_confirmation, :current_password, :user

  validates :password, :password_confirmation, :current_password, presence: true
  validate :current_password_match
  validate :password_match

  def current_password_match
    return if current_password.blank? || user.pwd_correct?(current_password)
    errors.add(:current_password, :invalid)
  end

  def password_match
    return if current_password.blank?
    errors.add(:password_confirmation, :invalid) if password != password_confirmation
  end
end
