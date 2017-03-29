require "spec_helper"
require "ostruct"

describe FactoryLite::Factory do
  SUT = FactoryLite::Factory
  Post = Struct.new(:title, :body)

  before(:all) do
    SUT.register(:post) do |f|
      f.constructor = lambda do |attrs|
        Post.new(attrs[:post][:title], attrs[:post][:body])
      end
      f.default_attrs = {
        title: "A Post",
        body: "Post body"
      }
    end
  end

  before(:each) do
    # restore default:
    SUT.config.model_accessor = :none
  end

  context "creating models" do
    it "sets the right attribute values" do
      post = SUT.create(:post)
      expect(post.title).to eq("A Post")
      expect(post.body).to eq("Post body")
    end

    it "can override values" do
      post = SUT.create(:post, title: "Another post")
      expect(post.title).to eq("Another post")
      expect(post.body).to eq("Post body")
    end
  end

  context "setting model accessors" do
    let(:post) { Post.new("A Post", "Post body") }

    it "accesses the model directly by default" do
      # default: SUT.config.model_accessor = :none
      expect(SUT.create(:post)).to eq(post)
    end

    it "can access the model from a trailblazer 1 operation" do
      expected = post
      SUT.config.model_accessor = :trailblazer1
      SUT.extend(:post, as: :tb1_post) do |f|
        f.constructor = lambda do |*|
          OpenStruct.new(model: expected)
        end
      end
      expect(SUT.create(:tb1_post)).to eq(post)
    end

    it "can access the model from a trailblazer 2 operation" do
      expected = post
      SUT.config.model_accessor = :trailblazer2
      SUT.extend(:post, as: :tb2_post) do |f|
        f.constructor = lambda do |*|
          { "model" => expected }
        end
      end
      expect(SUT.create(:tb2_post)).to eq(post)
    end

    it "can set a custom accessor" do
      expected = post
      SUT.config.model_accessor = ->(res) { res.custom }
      SUT.extend(:post, as: :custom_post) do |f|
        f.constructor = lambda do |*|
          OpenStruct.new(custom: expected)
        end
      end
      expect(SUT.create(:custom_post)).to eq(post)
    end

    it "can set accessors by factory" do
      expected = post
      SUT.config.model_accessor = :trailblazer2
      SUT.extend(:post, as: :inline_post) do |f|
        f.model_accessor = :none
        f.constructor = ->(*) { expected }
      end
      expect(SUT.create(:inline_post)).to eq(post)
    end
  end

  context "setting the attrs key" do
    it "uses the factory name by default" do
      SUT.extend(:post, as: :keyless_post) do |f|
        f.model_accessor = :none
        f.attrs_key = nil
        f.constructor = lambda do |attrs|
          Post.new(attrs[:title], attrs[:body])
        end
      end
      post = SUT.create(:keyless_post, {title: "bla", body: "blody"})
      expect(post.title).to eq("bla")
      expect(post.body).to eq("blody")
    end
  end

  context "dynamic attributes" do
    it "can receive callables as attribute generatos" do
      SUT.extend(:post, as: :random_post) do |f|
        f.default_attrs = {
          title: ->(*) { "Post ##{1+1}" }
        }
      end
      expect(SUT.create(:random_post).title).to eq("Post #2")
    end

    it "can create sequences" do
      SUT.extend(:post, as: :sequential_post) do |f|
        f.default_attrs = {
          title: sequence(1) { |n| "Post ##{n}" }
        }
      end
      expect(SUT.create(:sequential_post).title).to eq("Post #1")
      expect(SUT.create(:sequential_post).title).to eq("Post #2")
    end
  end
end
