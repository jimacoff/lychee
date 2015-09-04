RSpec.shared_examples 'workflow object' do |transitions:, state:|
  context "after transitions: #{transitions.join(', ')}" do
    before { transitions.each { |t| subject.send(:"#{t}!") } }
    it { is_expected.to have_attributes(workflow_state: state.to_s) }
  end
end
