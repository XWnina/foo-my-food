// constants.dart

// 正则表达式常量
// Instagram 用户名正则表达式：允许字母、数字、下划线和句号，长度在 1-30 之间
const String instagramUsernameRegexPattern = r'^[a-zA-Z0-9._]{1,30}$';

// 邮箱和电话号码的正则表达式
const String emailRegexPattern =
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9]+\.[a-zA-Z]+$";
const String phoneNumberRegexPattern = r'^\d{10}$';

// 错误提示信息
const String usernameTakenError = 'Username already taken';
const String emailInvalidError = 'Invalid email format';
const String emailTakenError = 'Email already taken';
const String phoneInvalidError = 'Phone number must be 10 digits';
const String phoneTakenError = 'Phone number already taken';
const String passwordMismatchError = 'Passwords do not match';
const String usernameInvalidError =
    'Username can only contain letters, numbers, periods, and underscores, and must be 1-30 characters long.';
const String usernameNotRegisteredError =
    'This username or email is not registered';
const String passwordIncorrectError = 'Incorrect password';
const String unexpectedError =
    'An unexpected error occurred. Please try again.';
// 其他常量
const String createAccountTitle = 'CREATE ACCOUNT';
const String loginButtonText = 'LOG IN';
const String forgetResetPasswordText = 'Forget/Reset Password';
const String createAccountButtonText = 'Create Account';

// 页面常量
const double inputFieldWidthFactor = 0.1;
const double buttonWidthFactor = 0.5;

// 定义基础 API URL
 const String baseApiUrl = 'http://127.0.0.1:8080/api'; // for ios
// const String baseApiUrl = 'http://10.0.2.2:8080/api';
