require 'spec_helper'

describe EmailAddressOptions do
  let(:affiliations) { ['student'] }
  let(:preferred_name) { 'Johnny' }
  let(:first_name) { 'John' }
  let(:middle_name) { 'Ben' }
  let(:last_name) { 'Doe' }
  let(:subject) { EmailAddressOptions.new(affiliations, preferred_name, first_name, middle_name, last_name).to_a }

  context 'when an employee' do
    let(:affiliations) { ['employee'] }

    context 'with a preferred_name' do
      it { expect(subject.to_a).to eql ['johnny.doe', 'john.doe', 'johnny.b.doe', 'john.b.doe', 'johnny.ben.doe', 'john.ben.doe'] }
    end

    context 'without a preferred_name' do
      let(:preferred_name) { nil }
      it { expect(subject.to_a).to eql ['john.doe', 'john.b.doe', 'john.ben.doe'] }
    end

    context 'with preferred_name same as first_name' do
      let(:preferred_name) { 'John' }
      it { expect(subject.to_a).to eql ['john.doe', 'john.b.doe', 'john.ben.doe'] }
    end

    context 'with a middle_name' do
      it { expect(subject.to_a).to eql ['johnny.doe', 'john.doe', 'johnny.b.doe', 'john.b.doe', 'johnny.ben.doe', 'john.ben.doe'] }
    end

    context 'without a middle_name' do
      let(:middle_name) { nil }
      it { expect(subject.to_a).to eql ['johnny.doe', 'john.doe'] }
    end
  end

  context 'when a student' do
    let(:affiliations) { ['student'] }
    it { expect(subject.to_a).to eql ['johnny.b.doe', 'john.b.doe', 'johnny.ben.doe', 'john.ben.doe'] }
  end

  context 'when an alumnus' do
    let(:affiliations) { ['alumnus'] }
    it { expect(subject.to_a).to eql [] }
  end
end
