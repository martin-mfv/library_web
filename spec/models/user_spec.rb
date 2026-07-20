require 'rails_helper'

RSpec.describe User, type: :model do
  subject(:user) { build(:user) }

  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_length_of(:name).is_at_most(255) }
end
