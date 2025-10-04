# frozen_string_literal: true

describe ClippingPolicy do
  subject(:policy) { described_class }

  let(:admin) { build_stubbed(:user, :admin) }
  let(:creator) { build_stubbed(:user) }
  let(:other_user) { build_stubbed(:user) }
  let(:clipping) { build_stubbed(:clipping, creator:) }

  permissions :index?, :show?, :create? do
    it 'grants access to admins' do
      expect(policy).to permit(admin, clipping)
    end

    it 'grants access to regular users' do
      expect(policy).to permit(creator, clipping)
    end

    it 'denies access to guests' do
      expect(policy).not_to permit(nil, clipping)
    end
  end

  permissions :update?, :destroy? do
    it 'grants access to admins' do
      expect(policy).to permit(admin, clipping)
    end

    it 'grants access to the creator' do
      expect(policy).to permit(creator, clipping)
    end

    it 'denies access to a different regular user' do
      expect(policy).not_to permit(other_user, clipping)
    end

    it 'denies access to guests' do
      expect(policy).not_to permit(nil, clipping)
    end
  end
end
