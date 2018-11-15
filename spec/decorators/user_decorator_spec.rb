require 'spec_helper'

describe UserDecorator do
  let(:user) { build_stubbed :user, name: "First Last", email: "email@example.com" }

  describe "#user_page_link" do
    it "link the name to the user page" do
      expect(user.decorate.user_page_link).to eq %(<a href="/users/#{user.id}">First Last</a>)
    end
  end

  describe "#ping_user_link" do
    it "like `#user_page_link`, but prefixed with an '@'" do
      expect(user.decorate.ping_user_link).
        to eq %(<a href="/users/#{user.id}">@<strong>First Last</strong></a>)
    end
  end

  describe "#angle_bracketed_email" do
    it "builds a string suitable for emails" do
      expect(user.decorate.angle_bracketed_email).to eq '"First Last" <email@example.com>'
    end
  end

  describe "#user_badge" do
    context "when user is an editor" do
      let(:user) { build_stubbed :user, :editor }

      specify { expect(user.decorate.user_badge).to eq %(<span class="label">editor</span>) }
    end

    context "when user is a helper" do
      let(:user) { build_stubbed :user, :helper }

      specify { expect(user.decorate.user_badge).to eq %(<span class="white-label">helper</span>) }
    end

    context "when user is neither an editor nor a helper" do
      let(:user) { build_stubbed :user }

      specify { expect(user.decorate.user_badge).to eq nil }
    end
  end
end
