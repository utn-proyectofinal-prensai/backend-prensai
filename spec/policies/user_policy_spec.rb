# frozen_string_literal: true

describe UserPolicy do
  subject(:policy) { described_class }

  let(:admin) { build_stubbed(:user, :admin) }
  let(:user) { build_stubbed(:user) }
  let(:other_user) { build_stubbed(:user) }

  permissions :index?, :create? do
    it 'allows admins and denies regular users' do
      expect(policy).to permit(admin, user)
      expect(policy).not_to permit(user, other_user)
    end
  end

  permissions :destroy? do
    it 'allows admins to destroy other users and not themselves' do
      expect(policy).to permit(admin, other_user)
      expect(policy).not_to permit(admin, admin)
    end

    it 'denies regular users' do
      expect(policy).not_to permit(user, other_user)
    end
  end

  permissions :show?, :change_password? do
    it 'allows admins or self-access and denies others' do
      expect(policy).to permit(admin, other_user)
      expect(policy).to permit(user, user)
      expect(policy).not_to permit(user, other_user)
    end
  end

  permissions :update? do
    it 'allows admins only' do
      expect(policy).to permit(admin, other_user)
      expect(policy).not_to permit(user, other_user)
    end
  end

  describe UserPolicy::Scope do
    subject(:scope) { described_class.new(current_user, User.all).resolve }

    let!(:admin_user) { create(:user, :admin) }
    let!(:regular_user) { create(:user) }

    context 'when current user is admin' do
      let(:current_user) { admin_user }

      it 'returns all users' do
        expect(scope).to contain_exactly(admin_user, regular_user)
      end
    end

    context 'when current user is regular user' do
      let(:current_user) { regular_user }

      it 'returns only the current user' do
        expect(scope).to contain_exactly(regular_user)
      end
    end
  end
end
