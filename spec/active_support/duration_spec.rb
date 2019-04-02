RSpec.describe ActiveSupport::Duration do
  describe '#human_to_s' do
    it do
      duration = ActiveSupport::Duration.build(3500)
      expect(duration.human_to_s).to eq '58m 20s'
    end

    it do
      duration = ActiveSupport::Duration.build(95)
      expect(duration.human_to_s).to eq '1m 35s'
    end

    it do
      duration = ActiveSupport::Duration.build(35)
      expect(duration.human_to_s).to eq '35s'
    end
  end
end
