# == Schema Information
#
# Table name: users
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  email      :string(255)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

require 'spec_helper'

describe User do
  
  before { @user = User.new(name: "Example User", email: "user@example.com", 
  	password: "foobar", password_confirmation: "foobar") }

  subject { @user }

  it { should respond_to(:name) }
  it { should respond_to(:email) }
  it { should respond_to(:password_digest) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:remember_token) }
  it { should respond_to(:admin) }
  it { should respond_to(:authenticate) }

  it { should be_valid }
  it { should_not be_admin }

  describe "with admin attribute set to 'true'" do
    before { @user.toggle!(:admin) }

    it { should be_admin }
  end

  describe "when name is not present" do
  	before { @user.name = "" }
  	it { should_not be_valid }
  end

  describe "when email is not present" do
  	before { @user.name = "Foo Bar" }
  	before { @user.email = "" }
  	it { should_not be_valid }
  end

  describe "when name is too long" do
  	before { @user.name = "a" * 51 }
  	it { should_not be_valid }
  end

  describe "when email format is invalid" do
  	it "should be invalid" do
  		addresses = %w(user@foo,com user_at_foo.org 
  			user@foo@bar_baz.com 
  			foo@bar+baz.com)
		  addresses.each do |addy|
		  	@user.email = addy
			  @user.should_not be_valid
		  end
  	end
  end

  describe "when email format is valid" do
  	it "should be valid" do
  		addresses = %w(user@foo.com user@foo.org 
  			user@fbaz.com 
  			foo+bar@baz.com)
		  addresses.each do |addy|
			  @user.email = addy
			  @user.should be_valid
		  end
    end
  end

  describe "when email is already taken" do
  	before do
  		@user_clone = @user.dup
  		@user_clone.email = @user.email.upcase
  		@user_clone.save
		end
	  it {should_not be_valid}
  end
  

  describe "when password is not present" do
    before { @user.password = @user.password_confirmation = " " }
    it { should_not be_valid }
  end

  describe "when passwords do not match" do
    before { @user.password_confirmation = "blah" }
    it { should_not be_valid }
  end

  describe "when password confirmation is nil" do
    before { @user.password_confirmation = nil }
    it { should_not be_valid }
  end

  describe "with a password that is too short" do
    before { @user.password = @user.password_confirmation = "a" * 5 }
    it { should_not be_valid }
  end

  describe "return value of authenticate method" do
    before { @user.save }
    let(:found_user) { User.find_by_email(@user.email) }

    describe "with valid password" do
      it { should == found_user.authenticate(@user.password)}
    end

    describe "with invalid password" do
      let(:user_for_invalid_pwd) { found_user.authenticate("invalid")}

      it { should_not == user_for_invalid_pwd}
      specify{user_for_invalid_pwd.should be_false}
    end
  end 

  describe "mixed-case email" do
    let(:mixed_case_email) { "foo@BAR.cOm" }

    it "should" do
      @user.email = mixed_case_email
      @user.save
      @user.reload.email.should == mixed_case_email.downcase
    end
  end

  describe "remember token" do
    before { @user.save }
    its(:remember_token) { should_not be_blank }
  end
end
