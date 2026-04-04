class User < ApplicationRecord
  has_secure_password
  attribute :admin, :boolean, default: false
  enum admin: { general: false, admin: true }
  scope :engineer, -> { where(admin_flag: false) }
end