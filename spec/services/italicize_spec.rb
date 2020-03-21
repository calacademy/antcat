require 'rails_helper'

describe Italicize do
  describe "#call" do
    it "adds <i> tags" do
      results = described_class['Atta']
      expect(results).to eq '<i>Atta</i>'
      expect(results.html_safe?).to eq true
    end
  end
end
