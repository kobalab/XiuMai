use XiuMai::Util::Msg; XiuMai::Util::Msg->new(\*DATA);
__DATA__
# -----------------------------------------------------------------------------
lang:English
# -----------------------------------------------------------------------------
error.400.message:Your browser sent a request that
	this server could not understand.
error.401.message:This server could not verify that you are authorized
	to access the document requested.
	Either you supplied the wrong credentials (e.g., bad password).
error.403.message:You don't have permission to access {$1} on this server.
error.404.message:The requested URL {$1} was not found on this server.
error.405.message:The requested method {$1} is not allowed for the URL {$2}.
error.406.message:An appropriate representation of the requested resource
	{$1} could not be found on this server.
error.500.message:The server encountered an internal error or misconfiguration
	and was unable to complete your request.
# -----------------------------------------------------------------------------
toolbar.user_menu.login:Login
toolbar.user_menu.logout:Logout
toolbar.resource_menu.edit:Edit
# -----------------------------------------------------------------------------
signup_form.title:SignUp
signup_form.login_name:Login Name (only alphanumeric characters)
signup_form.passwd:Password
signup_form.email:Email Address
signup_form.submit:SIGN UP
#
signup.error.no_login_name:Login name is not set.
signup.error.bad_login_name:{$1} is bad login name.
signup.error.no_passwd:Password is not set.
signup.error.already_taken:Login name {$1} is already taken.
# -----------------------------------------------------------------------------
login_form.title:Login
login_form.login_name:Login Name
login_form.passwd:Password
login_form.submit:LOGIN
# -----------------------------------------------------------------------------
folder.file_list.name:Name
folder.file_list.mtime:Last Modified
folder.file_list.size:Size
folder.file_list.type:Type
#
folder.mkfile_form.label:Add New File
folder.mkfile_form.filename:File Name
folder.mkfile_form.submit:ADD
#
folder.mkdir_form.label:Add New Folder
folder.mkdir_form.dirname:Folder Name
folder.mkdir_form.submit:CREATE
#
folder.rmdir_form.label:Remove This Folder
folder.rmdir_form.submit:REMOVE
#
resource.upload_form.label:Update This File
resource.upload_form.submit:UPLOAD
# -----------------------------------------------------------------------------
