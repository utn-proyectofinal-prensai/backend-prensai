# frozen_string_literal: true

describe User do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:role) }

    context 'when was created with regular login' do
      subject { build(:user) }

      it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
      it { is_expected.to validate_presence_of(:email) }
    end
  end

  describe 'enums' do
    it 'defines role enum' do
      expect(User.roles).to eq({ 'user' => 0, 'admin' => 1 })
    end

    it 'has user as default role' do
      user = User.new
      expect(user.role).to eq('user')
    end
  end

  describe 'role methods' do
    let(:user) { create(:user) }
    let(:admin) { create(:user, :admin) }

    it 'admin? returns correct boolean' do
      expect(user.admin?).to be false
      expect(admin.admin?).to be true
    end
  end

  context 'when was created with regular login' do
    let!(:user) { create(:user) }
    let(:full_name) { user.full_name }

    it 'returns the correct name' do
      expect(full_name).to eq(user.username)
    end
  end

  context 'when user has first_name' do
    let!(:user) { create(:user, first_name: 'John', last_name: 'Doe') }

    it 'returns the correct name' do
      expect(user.full_name).to eq('John Doe')
    end
  end
end
