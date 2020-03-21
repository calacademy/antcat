require 'rails_helper'

describe Detax do
  describe "#call" do
    context 'with unsafe tags' do
      let(:reference) { create :unknown_reference, citation: 'Latreille, 1809 <script>xss</script>' }

      it "sanitizes them" do
        expect(described_class["{ref #{reference.id}} <script>xss</script>"]).to_not include 'script'
      end
    end

    context "when input is nil" do
      specify { expect(described_class[nil]).to eq '' }
    end

    specify { expect(described_class['string'].html_safe?).to eq true }
  end
end
