require 'imyou/nickname'

RSpec.describe Imyou::Nickname do
  let(:user) { User.create!(name: 'user_name') }

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
      end
    end

    context '#partial_match_by_nickname' do
      subject { User.partial_match_by_nickname('az') }

      it 'should exists' do
        expect(subject).to be_exists
      end
    end

    context '#nicknames=' do
      it 'register new nicknames' do
        user.nicknames = %w(foo hoge bar)
        expect(user.nicknames).to match_array %w(foo hoge bar)
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