# Authentication Test Checklist

## Login Functionality Test

### 1. Main Authentication Screen
- [x] "시작하기" button (Guest login)
- [x] Google login button
- [x] Kakao login button
- [x] Email login button (새로 추가됨)

### 2. Email Login Screen Features
- [ ] Toggle between Login/Signup mode
- [ ] Email validation
- [ ] Password validation (min 6 chars for signup)
- [ ] Name field for signup
- [ ] Password visibility toggle
- [ ] Password reset functionality
- [ ] Loading states during authentication

### 3. Authentication Flow Test Cases

#### Guest Login
- [ ] Click "시작하기" → Should login as guest
- [ ] Navigate to home screen after success
- [ ] Show error if fails

#### Email Login Flow
1. Click "이메일로 계속하기" on main screen
2. Should navigate to EmailLoginScreen
3. Login Mode:
   - [ ] Enter valid email
   - [ ] Enter password
   - [ ] Click "로그인"
   - [ ] Should authenticate and redirect to home

4. Signup Mode:
   - [ ] Toggle to signup mode
   - [ ] Enter name
   - [ ] Enter email
   - [ ] Enter password (6+ chars)
   - [ ] Click "회원가입"
   - [ ] Should create account and auto-login

5. Password Reset:
   - [ ] Click "비밀번호를 잊으셨나요?"
   - [ ] Enter email in dialog
   - [ ] Should send reset email

### 4. Error Handling Test
- [ ] Invalid email format
- [ ] Wrong password
- [ ] Email already in use (signup)
- [ ] User not found (login)
- [ ] Network errors

### 5. Backend Integration Check
- [ ] Firebase Auth initialized ✅
- [ ] Auth state persisted across sessions
- [ ] User data stored in local storage
- [ ] Multiple accounts support

## Test Results

### Current Status:
- ✅ All runtime errors fixed (withValues → withOpacity)
- ✅ Email login UI created
- ✅ Email login button added to main auth screen
- ✅ Firebase integration ready
- ✅ App running successfully on Chrome

### Next Steps:
1. Manually test each authentication flow
2. Verify Firebase console for user creation
3. Check local storage for account persistence
4. Test error scenarios