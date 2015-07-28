require 'spec_helper'

describe ServiceObjects::HandleChange do
  let(:fixture) { 'create_user' }
  let(:change_hash) { JSON.parse(File.read("./spec/fixtures/#{fixture}.json")) }
  let(:trogdir_change) { TrogdirChange.new(change_hash) }
  subject { ServiceObjects::HandleChange.new(trogdir_change) }

  context 'when personal email created' do
    let(:fixture) { 'create_personal_email' }

    it 'does not call any service objects' do
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :skip)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end

  context 'when affiliation added' do
    context 'when a reprovisionable email exists' do
      let(:fixture) { 'update_person_add_affiliation' }
      before { UniversityEmail.create uuid: '00000000-0000-0000-0000-000000000000', address: 'bob.dole@biola.edu', state: :suspended }

      it 'calls ReprovisionGoogleAccount' do
        expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to receive(:call).and_return(:create)
        expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :create)
        expect(Workers::ChangeError).to_not receive(:perform_async)

        subject.call
      end
    end

    context "when a reprovisionable email doesn't exist" do
      let(:fixture) { 'create_user_without_university_email' }

      it 'calls AssignEmailAddress' do
        expect_any_instance_of(ServiceObjects::AssignEmailAddress).to receive(:call).and_return(:create)
        expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
        expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
        expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :create)
        expect(Workers::ChangeError).to_not receive(:perform_async)

        subject.call
      end
    end
  end

  context 'when university email created' do
    let(:fixture) { 'create_email' }

    it 'calls SyncGoogleAccount' do
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to receive(:call).and_return(:create)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :create)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end

  context 'when university email updated' do
    let(:fixture) { 'update_email' }

    it 'calls UpdateEmailAddress' do
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to receive(:call).and_return(:update)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :update)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end

  context 'when account info updated' do
    let(:fixture) { 'update_person' }

    it 'calls SyncGoogleAccount' do
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to receive(:call).and_return(:create)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :create)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end

  context 'when a group is joined' do
    let(:fixture) { 'join_group' }

    it 'calls JoinGoogleGroup' do
      allow(Settings).to receive_message_chain(:groups, :whitelist).and_return(['Politician', 'President'])
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to receive(:call).and_return(:update)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :update)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end

  context 'when a group is left' do
    let(:fixture) { 'leave_group' }

    it 'calls LeaveGoogleGroup' do
      allow(Settings).to receive_message_chain(:groups, :whitelist).and_return(['Politician', 'Congressman'])
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to receive(:call).and_return(:update)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :update)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end

  context 'when all affiliations removed' do
    let(:fixture) { 'update_person_remove_all_affiliations' }

    it 'calls DeprovisionGoogleAccount' do
      allow(Settings).to receive_message_chain(:groups, :whitelist).and_return(['Politician', 'President'])
      expect_any_instance_of(ServiceObjects::AssignEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::UpdateEmailAddress).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::SyncGoogleAccount).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::JoinGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::LeaveGoogleGroup).to_not receive(:call)
      expect_any_instance_of(ServiceObjects::DeprovisionGoogleAccount).to receive(:call).and_return(:update)
      expect_any_instance_of(ServiceObjects::ReprovisionGoogleAccount).to_not receive(:call)
      expect(Workers::ChangeFinish).to receive(:perform_async).with(kind_of(String), :update)
      expect(Workers::ChangeError).to_not receive(:perform_async)

      subject.call
    end
  end
end
