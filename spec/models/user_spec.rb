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
    it { is_expected.to define_enum_for(:role).with_values(user: 'user', admin: 'admin').backed_by_column_of_type(:string) }
  end

  describe 'defaults' do
    it 'sets default role to user' do
      user = User.new
      expect(user.role).to eq('user')
    end
  end

  describe '#admin?' do
    context 'when user is admin' do
      let(:user) { build(:user, role: 'admin') }

      it 'returns true' do
        expect(user.admin?).to be true
      end
    end

    context 'when user is not admin' do
      let(:user) { build(:user, role: 'user') }

      it 'returns false' do
        expect(user.admin?).to be false
      end
    end
  end

  describe '#user?' do
    context 'when user has user role' do
      let(:user) { build(:user, role: 'user') }

      it 'returns true' do
        expect(user.user?).to be true
      end
    end

    context 'when user is admin' do
      let(:user) { build(:user, role: 'admin') }

      it 'returns false' do
        expect(user.user?).to be false
      end
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
