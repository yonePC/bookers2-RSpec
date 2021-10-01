require 'rails_helper'

describe '[STEP2] ユーザログイン後のテスト' do
  let(:user) { create(:user) }
  let!(:other_user) { create(:user) }
  let!(:book) { create(:book, user: user) }
  let!(:other_book) { reate(:book, user: other_user) }

  before do
    visit new_user_session_path
    fill_in 'user[name]', with: user.name
    fill_in 'user[password]', with: user.password
    click_button 'Log in'
  end

  describe 'ヘッダーのテスト: ログインしている場合' do
    context 'リンクの内容を確認' do
      subject { current_path }

      it 'Homeを押すと、自分のユーザ詳細画面に遷移する' do
        home_link = find_all('a')[1].native.inner_text
        home_link = home_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link home_link
        is_expected.to eq '/users/' + user.id.to_s
      end
      it 'Usersを押すと、ユーザ一覧画面に遷移する' do
        users_link = find_all('a')[2].native.inner_text
        users_link = users_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link users_link
        is_expected.to eq '/users'
      end
      it 'Booksを押すと、投稿一覧画面に遷移する' do
        books_link = find_all('a')[3].native.inner_text
        books_link = books_link.gsub(/\n/, '').gsub(/\A\s*/, '').gsub(/\s*\Z/, '')
        click_link books_link
        is_expected.to eq '/books'
      end
    end #リンクの内容を確認
  end #ヘッダーのテスト: ログインしている場合

  describe '投稿一覧画面のテスト' do
    bofore do
      visit books_path
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/books'
      end
      it '自分と他人の画像のリンク先が正しい' do
        expect(page).to have_link '', href: user_path(book.user)
        expect(page).to have_link '', href: user_path(other_book.user)
      end
      it '自分の投稿と他人の投稿のタイトルのリンク先がそれぞれ正しい' do
        expect(page).to have_link book.title, href: book_path(book)
        expect(page).to have_link other_book.title, href: book_path(other_book)
      end
      it '自分の投稿と他人の投稿のオピニオンが表示される' do
        expect(page).to have_content book.body
        expect(page).to have_content other_book.body
      end
    end #表示内容の確認

    context 'サイドバーの確認' do
      it '自分の名前と紹介文が表示される' do
        expect(page).to have_content user.name
        expect(page).to have_content user.introduction
      end
      it '自分のユーザ編集画面へのリンクが存在する' do
        expect(page).to have_link '', href: edit_user_path(user)
      end
      it '「New book」と表示される' do
        expect(page).to have_content 'New book'
      end
      it 'titleフォームが表示される' do
        expect(page).to have_field 'book[title]'
      end
      it 'titleフォームに値が入っていない' do
        expect(find_field('book[title]').text).to be_blank
      end
      it 'opinionフォームが表示される' do
        expect(page).to have_field 'book[body]'
      end
      it 'opinionフォームに値が入っていない' do
        expect(find_field('book[body]').text).to be_blank
      end
      it 'Create Bookボタンが表示される' do
        expect(page).to have_button 'Create Book'
      end
    end #サイドバーの確認

    context '投稿成功のテスト' do
      before do
        fill_in 'book[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect{ click_button 'Create Book' }.to change(user.books, :count).by(1)
      end
      it 'リダイレクト先が、保存できた投稿の詳細画面になっている' do
        click_button 'Create Book'
        expect(current_path).to eq '/books/' + Book.last.id.to_s
      end
    end #投稿成功のテスト
  end #投稿一覧画面のテスト


  describe '自分の投稿詳細画面のテスト' do
    before do
      visit book_path(book)
    end

    context '表示内容の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/books/' + book.id.to_s
      end
      it '「Book detail」と表示される' do
        expect(page).to have_content 'Book detail'
      end
      it 'ユーザ画像・名前のリンク先が正しい' do
        expect(page).to have_link book.user.name, href: user_path(book.user)
      end
      it '投稿のtitleが表示される' do
        expect(page).to have_content book.title
      end
      it '投稿のopinionが表示される' do
        expect(page).to have_content book.body
      end
      it '投稿の編集リンクが表示される' do
        expect(page).to have_link 'Edit', href: edit_book_path(book)
      end
      it '投稿の削除リンクが表示される' do
        expect(page).to have_link 'Destroy', href: book_path(book)
      end
    end #表示内容の確認

    context 'サイドバーの確認' do
      it '自分の名前と紹介文が表示される' do
        expect(page).to have_content user.name
        expest(page).to have_content user.introduction
      end
      it '自分のユーザ編集へのリンクが存在する' do
        expect(page).to have_link '', href: edit_user_path(user)
      end
      it '「New book」と表示される' do
        expect(page).to have_content 'New book'
      end
      it 'titleフォームが表示される' do
        expect(page).to have_field 'book[title]'
      end
      it 'titleフォームに値が入っていない' do
        expect(find_field('book[title]').text).to be_blank
      end
      it 'opinionフォームが表示されている' do
        expect(page).to have_field 'book[body]'
      end
      it 'opinionフォームに値が入っていない' do
        ecpect(find_field('book[body]').text).to be_blank
      end
      it 'Create Bookボタンが表示されている'do
        expect(page).to have_button 'Create Book'
      end
    end #サイドバーの確認

    context '投稿成功のテスト' do
      before do
        fill_in 'book[title]', with: Faker::Lorem.characters(number: 5)
        fill_in 'book[body]', with: Faker::Lorem.characters(number: 20)
      end

      it '自分の新しい投稿が正しく保存される' do
        expect { click_button 'Create Book' }.to change(user.books, :count).by(1)
      end
    end #

    context '編集リンクのテスト' do
      it '編集画面に遷移する' do
        click_link 'Edit'
        expect(current_path).to eq '/books/' + book.id.to_s + '/edit'
      end
    end #編集リンクのテスト

    context '削除リンクのテスト' do
      before do
        click_link 'Destroy'
      end

      it '正しく削除される' do
        expect(Book.where(id: book.id).count).to eq 0
      end
      it 'リダイレクト先が、投稿一覧画面になっている' do
        expect(current_path).to eq '/books'
      end
    end #削除リンクのテスト
  end #自分の投稿詳細画面のテスト

  describe '自分の投稿編集画面のテスト' do
    before do
      visit edit_book_path(book)
    end

    context '表示の確認' do
      it 'URLが正しい' do
        expect(current_path).to eq '/books/' + book.id.to_s + '/edit'
      end
      it '「Editing Book」と表示される' do
        expect(page).to have_content 'Editing Book'
      end
      it 'title編集フォームが表示される' do
        expect(page).to have_field 'book[title]', with: book.title
      end
      it 'opinion編集フォームが表示される' do
        expect(page).to have_field 'book[body]', with: book.body
      end
      it 'Update Bookボタンが表示される' do
        expect(page).to have_button 'Update Book'
      end
      it 'Showリンクが表示される' do
        expect(page).to have_link 'Show', href: book_path(book)
      end
      it 'Backリンクが表示される' do
        expect(page).to have_link 'Back', href: books_path
      end
    end #表示の確認
    
    context '編集成功のテスト' do
      before do 
        @book_old_title = book.title
        @book_old_body = book.body
        fill_in 'book[title]', with: Faker::Lorem.characters(number: 4)
        fill_in 'book[body]', with: Faker::Lorem.characters(number: 19)
        click_button 'Update Book'
      end
      
      it 'titleが正しく更新される' do
        expect(book.reload.title).not_to eq @book_old_title
      end
      it 'bodyが正しく更新される' do
        expect(book.reload.body).not_to eq @book_old_body
      end
      it 'リダイレクト先が、更新した投稿の詳細画面になっている' do
        expect(current_path).to eq '/books/' + book.id.to_s
        expect(page).to have_content 'Book detail'
      end
    end #編集成功のテスト
  end #自分の投稿編集画面のテスト


end #ユーザログイン後のテスト