# frozen_string_literal: true

describe MentionPolicy do
  subject(:policy) { described_class }

  let(:record) { build_stubbed(:mention) }
  let(:admin) { build_stubbed(:user, :admin) }
  let(:user) { build_stubbed(:user) }

  permissions :index?, :create?, :update?, :destroy? do
    it 'allows admins' do
      expect(policy).to permit(admin, record)
    end

    it 'allows regular users' do
      expect(policy).to permit(user, record)
    end

    it 'denies guests' do
      expect(policy).not_to permit(nil, record)
    end
  end
end
