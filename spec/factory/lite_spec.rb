require "spec_helper"

describe Factory::Lite do
  it "has a version number" do
    expect(Factory::Lite::VERSION).not_to be nil
  end

  it "does something useful" do
    expect(false).to eq(true)
  end
end
