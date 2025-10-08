class PrizeSubmission < ApplicationRecord
  belongs_to :player
  
  validates :first_name, :last_name, :email, :address1, :city, :state, :country, :zip, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :player_id, uniqueness: true
  
  def full_name
    "#{first_name} #{last_name}"
  end
  
  def full_address
    address_parts = [address1, address2, city, state, country, zip].compact
    address_parts.join(", ")
  end
end
