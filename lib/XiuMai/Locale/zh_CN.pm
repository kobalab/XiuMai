use XiuMai::Util::Msg; XiuMai::Util::Msg->new(\*DATA);
__DATA__
# -----------------------------------------------------------------------------
lang:简体中文
# -----------------------------------------------------------------------------
error.400.message:请求有错。
error.401.message:需要授权。账号或密码应该有错。
error.403.message:禁止访问 {$1} 。
error.404.message:找不到网页 {$1}。
error.405.message:请求方法 {$1} 在 {$2} 上不允许。
error.406.message:{$1} 没有恰当的表示方式。
error.500.message:内部服务器错误。无法完成对请求的处理。
# -----------------------------------------------------------------------------
toolbar.user_menu.login:登录
toolbar.user_menu.logout:注销
toolbar.resource_menu.edit:编辑
# -----------------------------------------------------------------------------
signup_form.title:注册
signup_form.login_name:账号(字母数字)
signup_form.passwd:密码
signup_form.email:电子邮件
signup_form.submit:注册
#
signup.error.no_login_name:需要输入账号。
signup.error.bad_login_name:账号 “{$1}” 不允许。
signup.error.no_passwd:需要输入密码。
signup.error.already_taken:账号 “{$1}” 是已经使用的。
# -----------------------------------------------------------------------------
login_form.title:登录
login_form.login_name:账号
login_form.passwd:密码
login_form.submit:登录
# -----------------------------------------------------------------------------
folder.file_list.name:名称
folder.file_list.mtime:修改日期
folder.file_list.size:大小
folder.file_list.type:种类
#
folder.mkfile_form.label:添加新文件
folder.mkfile_form.filename:文件名
folder.mkfile_form.submit:添加
#
folder.mkdir_form.label:新建文件夹
folder.mkdir_form.dirname:文件夹
folder.mkdir_form.submit:新建
#
folder.rmdir_form.label:删除文件夹
folder.rmdir_form.submit:删除
#
resource.upload_form.label:更新文件
resource.upload_form.submit:上载
# -----------------------------------------------------------------------------
