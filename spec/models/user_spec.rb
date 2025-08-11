# frozen_string_literal: true

describe User do
  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
    it { is_expected.to validate_presence_of(:role) }

    context 'when was created with regular login' do
      subject { build(:user) }

      it { is_expected.to validate_uniqueness_of(:email).case_insensitive.scoped_to(:provider) }
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

  describe '.from_social_provider' do
    context 'when user does not exists' do
      let(:params) { attributes_for(:user) }

      it 'creates the user' do
        expect {
          described_class.from_social_provider('provider', params)
        }.to change(described_class, :count).by(1)
      end

      it 'creates user with default role' do
        user = described_class.from_social_provider('provider', params)
        expect(user.role).to eq('user')
      end
    end

    context 'when the user exists' do
      let!(:user)  { create(:user, provider: 'provider', uid: 'user@example.com') }
      let(:params) { attributes_for(:user).merge('id' => 'user@example.com') }

      it 'returns the given user' do
        expect(described_class.from_social_provider('provider', params))
          .to eq(user)
      end
    end
  end
end
