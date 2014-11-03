use XiuMai::Util::Msg; XiuMai::Util::Msg->new(\*DATA);
__DATA__
# -----------------------------------------------------------------------------
lang:日本語
# -----------------------------------------------------------------------------
error.400.message:不正なリクエストです。
error.401.message:認証エラーです。ログイン名、パスワードをご確認ください。
error.403.message:{$1} に対するアクセス権がありません。
error.404.message:要求されたURL {$1} はこのサーバにありません。
error.405.message:要求されたメソッド {$1} は、{$2} に対して許可されていません。
error.406.message:要求された資源 {$1}
	に対する適切な表現がこのサーバにありません。
error.500.message:内部エラーまたは設定ミスのため、リクエストを完了できませんでした。
# -----------------------------------------------------------------------------
toolbar.user_menu.login:ログイン
toolbar.user_menu.logout:ログアウト
toolbar.resource_menu.edit:編集
# -----------------------------------------------------------------------------
signup_form.title:ユーザ登録
signup_form.login_name:ログイン名(英数字)
signup_form.passwd:パスワード
signup_form.email:メールアドレス
signup_form.submit:ユーザ登録
#
signup.error.no_login_name:ログイン名が指定されていません。
signup.error.bad_login_name:“{$1}” はログイン名に使用できません。
signup.error.no_passwd:パスワードが指定されていません。
signup.error.already_taken:ログイン名 “{$1}” はすでに使用されています。
# -----------------------------------------------------------------------------
login_form.title:ログイン
login_form.login_name:ログイン名
login_form.passwd:パスワード
login_form.submit:ログイン
# -----------------------------------------------------------------------------
folder.file_list.name:名前
folder.file_list.mtime:変更日
folder.file_list.size:サイズ
folder.file_list.type:種類
#
folder.mkfile_form.label:新規ファイル
folder.mkfile_form.filename:ファイル名
folder.mkfile_form.submit:追加
#
folder.mkdir_form.label:新規フォルダ
folder.mkdir_form.dirname:フォルダ名
folder.mkdir_form.submit:作成
#
folder.rmdir_form.label:フォルダ削除
folder.rmdir_form.submit:削除
#
resource.upload_form.label:ファイル入替
resource.upload_form.submit:アップロード
# -----------------------------------------------------------------------------
