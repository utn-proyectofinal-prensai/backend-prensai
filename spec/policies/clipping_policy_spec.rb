# frozen_string_literal: true

describe ClippingPolicy do
  subject(:policy) { described_class }

  let(:admin) { build_stubbed(:user, :admin) }
  let(:creator) { build_stubbed(:user) }
  let(:other_user) { build_stubbed(:user) }
  let(:clipping) { build_stubbed(:clipping, creator:) }

  permissions :index?, :show?, :create? do
    it 'allows authenticated users' do
      expect(policy).to permit(admin, clipping)
      expect(policy).to permit(creator, clipping)
      expect(policy).to permit(other_user, clipping)
    end

    it 'denies unauthenticated users' do
      expect(policy).not_to permit(nil, clipping)
    end
  end

  permissions :update?, :destroy? do
    it 'allows admins and creators but denies others' do
      expect(policy).to permit(admin, clipping)
      expect(policy).to permit(creator, clipping)
      expect(policy).not_to permit(other_user, clipping)
      expect(policy).not_to permit(nil, clipping)
    end
  end
end
