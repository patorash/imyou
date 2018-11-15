require 'imyou/nickname'

RSpec.describe Imyou::Nickname do
  let(:user) { User.create!(name: 'user_name') }
  let(:no_name_user) { NoNameUser.create! }

  it 'should not have imyou' do
    expect(NotUser).not_to have_imyou
  end

  it "should be a footprinter" do
    expect(User).to have_imyou
  end

  context 'If nickname is already registered,' do
    before do
      %w(foo bar baz).each do |nickname|
        user.imyou_nicknames.create!(name: nickname)
        no_name_user.imyou_nicknames.create!(name: nickname)
      end
    end

    it 'user should get nicknames' do
      expect(user.nicknames).to match_array %w(foo bar baz)
    end

    it 'Same nickname should not be register by validation.' do
      expect do
        user.imyou_nicknames.create!(name: 'foo')
      end.to raise_error ActiveRecord::RecordInvalid
    end

    it 'Same nickname should not be register by restriction.' do
      expect do
        nickname = user.imyou_nicknames.build(name: 'foo')
        nickname.save!(validate: false)
      end.to raise_error ActiveRecord::RecordNotUnique
    end

    context '#with_nickname' do
      subject { User.with_nicknames.first }

      it 'should get nicknames' do
        expect(user.nicknames).to match_array %w(foo bar baz)
      end
    end

    context '#match_by_nickname' do
      it 'should exists' do
        expect(User.match_by_nickname('baz')).to be_exists
        expect(User.match_by_nickname('az')).not_to be_exists

        expect(NoNameUser.match_by_nickname('baz')).to be_exists
        expect(NoNameUser.match_by_nickname('az')).not_to be_exists
      end

      it 'should search by users.name' do
        expect(User.match_by_nickname('user_name')).to be_exists
      end

      context 'If with_name_column = false' do
        it 'should not search by users.name' do
          expect(User.match_by_nickname('user_name', with_name_column: false)).not_to be_exists
        end
      end
    end

    context '#partial_match_by_nickname' do
      it 'should exists' do
        expect(User.partial_match_by_nickname('az')).to be_exists
        expect(NoNameUser.partial_match_by_nickname('az')).to be_exists
      end

      it 'should search by users.name' do
        expect(User.partial_match_by_nickname('user')).to be_exists
        expect(User.partial_match_by_nickname('er_na')).to be_exists
      end

      context 'If with_name_column = false' do
        it 'should not search by users.name' do
          expect(User.partial_match_by_nickname('user', with_name_column: false)).not_to be_exists
        end
      end
    end

    context '#nicknames=' do
      it 'register new nicknames' do
        user.nicknames = %w(foo hoge bar)
        expect(user.nicknames).to match_array %w(foo hoge bar)
      end

      it 'can remove nicknames' do
        user.nicknames = []
        expect(user.nicknames).to eq []
      end

      it 'can remove nicknames by nil' do
        user.nicknames = nil
        expect(user.nicknames).to eq []
      end
    end

    context '#add_nickname' do
      it 'register new nickname' do
        expect(user.add_nickname('hoge')).to be_truthy
        expect(user.nicknames).to match_array %w(foo hoge bar baz)
      end
    end

    context '#remove_nickname' do
      it 'remove nickname' do
        expect(user.remove_nickname('foo')).to be_truthy
        expect(user.nicknames).to match_array %w(bar baz)
      end
    end

    context '#remove_all_nicknames' do
      it 'remove all nicknames' do
        expect do
          user.remove_all_nicknames
        end.to change { user.nicknames.size }.from(3).to(0)
      end
    end
  end
end