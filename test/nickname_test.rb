require 'test_helper'

describe Imyou::Nickname do
  let(:user) { User.create!(name: 'user_name') }
  let(:no_name_user) { NoNameUser.create! }
  let(:new_user) { User.new(name: 'new_user_name') }
  let(:invalid_user) { User.new(name: '') }

  it 'should not have imyou' do
    expect(NotUser).wont_be :has_imyou?
  end

  it "should be a footprinter" do
    expect(User).must_be :has_imyou?
  end

  describe 'If nickname is already registered,' do
    before do
      %w(foo bar baz).each do |nickname|
        user.imyou_nicknames.create!(name: nickname)
        no_name_user.imyou_nicknames.create!(name: nickname)
      end
    end

    it 'user should get nicknames' do
      expect(user.nicknames).must_equal %w(foo bar baz)
    end

    it 'Same nickname should not be register by validation.' do
      assert_raises ActiveRecord::RecordInvalid do
        user.imyou_nicknames.create!(name: 'foo')
      end
    end

    it 'Same nickname should not be register by restriction.' do
      assert_raises ActiveRecord::RecordNotUnique do
        nickname = user.imyou_nicknames.build(name: 'foo')
        nickname.save!(validate: false)
      end
    end

    describe '#with_nickname' do
      subject { User.with_nicknames.first }

      it 'should get nicknames' do
        expect(user.nicknames).must_equal %w(foo bar baz)
      end
    end

    describe '#match_by_nickname' do
      it 'should exists' do
        expect(User.match_by_nickname('baz')).must_be :exists?
        expect(User.match_by_nickname('az')).wont_be :exists?

        expect(NoNameUser.match_by_nickname('baz')).must_be :exists?
        expect(NoNameUser.match_by_nickname('az')).wont_be :exists?
      end

      it 'should search by users.name' do
        expect(User.match_by_nickname('user_name')).must_be :exists?
      end

      describe 'If with_name_column = false' do
        it 'should not search by users.name' do
          expect(User.match_by_nickname('user_name', with_name_column: false)).wont_be :exists?
        end
      end
    end

    describe '#partial_match_by_nickname' do
      it 'should exists' do
        expect(User.partial_match_by_nickname('az')).must_be :exists?
        expect(NoNameUser.partial_match_by_nickname('az')).must_be :exists?
      end

      it 'should search by users.name' do
        expect(User.partial_match_by_nickname('user')).must_be :exists?
        expect(User.partial_match_by_nickname('er_na')).must_be :exists?
      end

      describe 'If with_name_column = false' do
        it 'should not search by users.name' do
          expect(User.partial_match_by_nickname('user', with_name_column: false)).wont_be :exists?
        end
      end
    end

    describe '#nicknames=' do
      describe 'If user is registerd,' do
        it 'register new nicknames' do
          user.nicknames = %w(foo hoge bar)
          expect(user.nicknames).must_match_array %w(foo hoge bar)
        end

        it 'can remove nicknames' do
          user.nicknames = []
          expect(user.nicknames).must_equal []
        end

        it 'can remove nicknames by nil' do
          user.nicknames = nil
          expect(user.nicknames).must_equal []
        end
      end

      describe 'If user is new_record,' do
        it 'build new nicknames' do
          new_user.nicknames = %w(foo hoge bar)
          expect(new_user.save_with_nicknames).must_equal true
          expect(new_user.imyou_nicknames.all?(&:persisted?)).must_equal true
          expect(new_user.nicknames).must_match_array %w(foo hoge bar)
        end

        it 'can remove nicknames' do
          new_user.nicknames = []
          expect(new_user.save_with_nicknames).must_equal true
          expect(new_user.nicknames).must_equal []
        end

        it 'can remove nicknames by nil' do
          new_user.nicknames = nil
          expect(new_user.save_with_nicknames).must_equal true
          expect(new_user.nicknames).must_equal []
        end
      end

      describe 'If user is invalid,' do
        it 'cannot save' do
          invalid_user.nicknames = %w(foo hoge bar)
          expect(invalid_user.save_with_nicknames).must_equal false
          expect(invalid_user.imyou_nicknames.all?(&:new_record?)).must_equal true
          expect(invalid_user.nicknames).must_match_array %w(foo hoge bar)
        end

        it 'cannot save!' do
          invalid_user.nicknames = %w(foo hoge bar)
          assert_raises ActiveRecord::RecordInvalid do
            invalid_user.save_with_nicknames!
          end
        end
      end
    end

    describe '#add_nickname' do
      it 'register new nickname' do
        expect(user.add_nickname('hoge')).must_be_instance_of Imyou::Nickname
        expect(user.nicknames).must_match_array %w(foo hoge bar baz)
      end
    end

    describe '#remove_nickname' do
      describe 'If user registered' do
        it 'remove nickname' do
          expect(user.remove_nickname('foo')).must_equal true
          expect(user.nicknames).must_match_array %w(bar baz)
        end
      end

      describe 'If user is new_record,' do
        before do
          new_user.nicknames = %w(foo bar baz)
        end

        it 'remove nickname' do
          expect(new_user.remove_nickname('foo')).must_equal true
          expect(new_user.nicknames).must_match_array %w(bar baz)
        end
      end
    end

    describe '#remove_all_nicknames' do
      describe 'If user registered' do
        it 'remove all nicknames' do
          expect(user.nicknames.size).must_equal 3
          user.remove_all_nicknames
          expect(user.nicknames.size).must_equal 0
        end
      end

      describe 'If user is new_record,' do
        before do
          new_user.nicknames = %w(foo bar baz)
        end

        it 'remove all nicknames' do
          expect(new_user.nicknames.size).must_equal 3
          new_user.remove_all_nicknames
          expect(new_user.nicknames.size).must_equal 0
        end
      end
    end

    # TODO: accepts_nested_attributes_forのテストを書く
    describe 'accepts_nested_attributes_for' do
      it 'should register nicknames' do
        params = {
            imyou_nicknames_attributes: [
                { name: 'hoge' },
                { name: 'piyo' },
                { name: 'fuga' },
            ]
        }
        expect(user.nicknames.size).must_equal 3
        user.update(params)
        expect(user.nicknames.size).must_equal 6
        expect(user.nicknames).must_match_array %w(foo bar baz hoge piyo fuga)
      end

      it 'should destroy nicknames' do
        params = {
            imyou_nicknames_attributes: [
                { id: user.imyou_nicknames.first.id, _destroy: '1' },
                { id: user.imyou_nicknames.second.id, _destroy: '1' }
            ]
        }
        expect(user.nicknames.size).must_equal 3
        user.update(params)
        expect(user.nicknames.size).must_equal 1
        expect(user.nicknames).must_match_array %w(baz)
      end

      it 'should reject blank name attributes' do
        params = {
            imyou_nicknames_attributes: [
                { name: 'hoge' },
                { name: 'piyo' },
                { name: '' }, # reject
            ]
        }
        expect(user.nicknames.size).must_equal 3
        user.update(params)
        expect(user.nicknames.size).must_equal 5
        expect(user.nicknames).must_match_array %w(foo bar baz hoge piyo)
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
        expect(user.nicknames).must_match_array %w(piyo baz hoge)
      end
    end
  end
end