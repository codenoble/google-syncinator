require 'spec_helper'

describe Workers::ChangeError do
  it 'logs an error in Trogdir' do
    expect_any_instance_of(Trogdir::APIClient::ChangeSyncs).to receive_message_chain(:error, :perform).and_return(double(success?: true))
    Workers::ChangeError.new.perform '12345', 'Testing'
  end
end
