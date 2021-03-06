require 'imyou/nickname'

RSpec.describe Imyou::Nickname do
  let(:user) { User.create!(name: 'user_name') }
  let(:no_name_user) { NoNameUser.create! }
  let(:new_user) { User.new(name: 'new_user_name') }
  let(:invalid_user) { User.new(name: '') }

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

    describe '#nicknames=' do
      context 'If user is registerd,' do
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

      context 'If user is new_record,' do
        it 'build new nicknames' do
          new_user.nicknames = %w(foo hoge bar)
          expect(new_user.save_with_nicknames).to be true
          expect(new_user.imyou_nicknames.all?(&:persisted?)).to be true
          expect(new_user.nicknames).to match_array %w(foo hoge bar)
        end

        it 'can remove nicknames' do
          new_user.nicknames = []
          expect(new_user.save_with_nicknames).to be true
          expect(new_user.nicknames).to eq []
        end

        it 'can remove nicknames by nil' do
          new_user.nicknames = nil
          expect(new_user.save_with_nicknames).to be true
          expect(new_user.nicknames).to eq []
        end
      end

      context 'If user is invalid,' do
        it 'cannot save' do
          invalid_user.nicknames = %w(foo hoge bar)
          expect(invalid_user.save_with_nicknames).to be false
          expect(invalid_user.imyou_nicknames.all?(&:new_record?)).to be true
          expect(invalid_user.nicknames).to match_array %w(foo hoge bar)
        end

        it 'cannot save!' do
          invalid_user.nicknames = %w(foo hoge bar)
          expect {
            invalid_user.save_with_nicknames!
          }.to raise_error ActiveRecord::RecordInvalid
        end
      end
    end

    context '#add_nickname' do
      it 'register new nickname' do
        expect(user.add_nickname('hoge')).to be_truthy
        expect(user.nicknames).to match_array %w(foo hoge bar baz)
      end
    end

    describe '#remove_nickname' do
      context 'If user registered' do
        it 'remove nickname' do
          expect(user.remove_nickname('foo')).to be_truthy
          expect(user.nicknames).to match_array %w(bar baz)
        end
      end

      context 'If user is new_record,' do
        before do
          new_user.nicknames = %w(foo bar baz)
        end

        it 'remove nickname' do
          expect(new_user.remove_nickname('foo')).to be_truthy
          expect(new_user.nicknames).to match_array %w(bar baz)
        end
      end
    end

    describe '#remove_all_nicknames' do
      context 'If user registered' do
        it 'remove all nicknames' do
          expect do
            user.remove_all_nicknames
          end.to change { user.nicknames.size }.from(3).to(0)
        end
      end

      context 'If user is new_record,' do
        before do
          new_user.nicknames = %w(foo bar baz)
        end

        it 'remove all nicknames' do
          expect do
            new_user.remove_all_nicknames
          end.to change { new_user.imyou_nicknames.size }.from(3).to(0)
        end
      end
    end

    # TODO: accepts_nested_attributes_forのテストを書く
    context 'accepts_nested_attributes_for' do
      it 'should register nicknames' do
        params = {
            imyou_nicknames_attributes: [
                { name: 'hoge' },
                { name: 'piyo' },
                { name: 'fuga' },
            ]
        }
        expect do
          user.update(params)
        end.to change { user.nicknames.size }.from(3).to(6)
        expect(user.nicknames).to match_array %w(foo bar baz hoge piyo fuga)
      end

      it 'should destroy nicknames' do
        params = {
            imyou_nicknames_attributes: [
                { id: user.imyou_nicknames.first.id, _destroy: '1' },
                { id: user.imyou_nicknames.second.id, _destroy: '1' }
            ]
        }
        expect do
          user.update(params)
        end.to change { user.nicknames.size }.from(3).to(1)
        expect(user.nicknames).to match_array %w(baz)
      end

      it 'should reject blank name attributes' do
        params = {
            imyou_nicknames_attributes: [
                { name: 'hoge' },
                { name: 'piyo' },
                { name: '' }, # reject
            ]
        }
        expect do
          user.update(params)
        end.to change { user.nicknames.size }.from(3).to(5)
        expect(user.nicknames).to match_array %w(foo bar baz hoge piyo)
      end

      it 'complex conditions' do
        params = {
            imyou_nicknames_attributes: [
                { name: 'hoge' }, # create
                { id: user.imyou_nicknames.first.id, _destroy: '1' }, # destroy
                { id: user.imyou_nicknames.second.id, name: 'piyo' }, # update
                { id: user.imyou_nicknames.last.id, name: '' }, #reject(not update)
            ]
        }
        user.update(params)
        expect(user.nicknames).to match_array %w(piyo baz hoge)
      end
    end
  end
end