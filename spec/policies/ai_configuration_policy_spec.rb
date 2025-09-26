# frozen_string_literal: true

describe AiConfigurationPolicy do
  subject(:policy) { described_class }

  let(:record) { build_stubbed(:ai_configuration) }
  let(:admin) { build_stubbed(:user, :admin) }
  let(:user) { build_stubbed(:user) }

  permissions :index?, :update? do
    it 'allows admins' do
      expect(policy).to permit(admin, record)
    end

    it 'denies regular users' do
      expect(policy).not_to permit(user, record)
    end
  end
end
