require 'spec_helper'

describe "MicropostPages" do

	subject { page }

	let(:user) { FactoryGirl.create(:user) }
	before { sign_in user }

	describe "micropost creation" do
	  before { visit root_path }

	  describe "with invalid info" do

	  	it "should not create a micropost" do
	  	  expect { click_button "Post" }.should_not change(Micropost, :count)
	  	end

	  	describe "error messages" do
	  	  before { click_button "Post" }
	  	  it { should have_content('error') }
	  	end
	  end

	  describe "with valid info" do

	  	before { fill_in 'micropost_content', with: "Lorem ipsum" }
	  	it "should create a micropost" do
	  		expect { click_button "Post" }.should change(Micropost, :count).by(1)
	  	end
	  end
 	end

 	describe "micropost destruction" do
 	  before { FactoryGirl.create(:micropost, user: user) }

 	  describe "as correct user" do
 	  	before { visit root_path }
 	  	it "should delete a micropost" do
 	  	  expect { click_link "delete" }.should change(Micropost, :count).by(-1)
 	  	end
 	  end

 	  describe "as incorrect user" do
 	  	let(:wrong_user) { FactoryGirl.create(:user) }
 	    let(:mp) { FactoryGirl.create(:micropost, user: wrong_user) }

 	  	before do
 	  	  visit user_path(wrong_user)
 	  	end

 	  	it { should_not have_selector('a', text: "delete") }

 	  	describe "should not be able to issue delete request" do
 	  		before { delete micropost_path(mp) }
 	  		specify { response.should redirect_to(root_path) }
 	  	end
 	  end
 	end
end