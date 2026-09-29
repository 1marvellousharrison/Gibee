import 'package:flutter/material.dart';

import '../models.dart';
import '../session.dart';
import '../theme/app_theme.dart';
import '../widgets/neu.dart';

/// Shared striped backdrop + title for all auth screens.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  NeuBox(
                    radius: 34,
                    blur: 14,
                    padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 42),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: NeuBox(
                            radius: 30,
                            inset: true,
                            blur: 10,
                            padding: const EdgeInsets.all(18),
                            child: Icon(
                              Icons.chat_bubble_rounded,
                              size: 42,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 28),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: AppText.title1.copyWith(fontSize: 26),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: AppText.body.copyWith(
                            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6),
                          ),
                        ),
                        const SizedBox(height: 28),
                        child,
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key, required this.session});

  final Session session;

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController(text: 'david@example.com');
  final _password = TextEditingController(text: 'demo1234');
  bool _remember = true;
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _signIn() {
    if (_email.text.trim().isEmpty || !_email.text.contains('@')) {
      _toast('Please enter a valid email.');
      return;
    }
    if (_password.text.length < 6) {
      _toast('Password must be at least 6 characters.');
      return;
    }
    widget.session.signIn(AppUser(name: 'David Lee', email: _email.text.trim(), phone: '+1 555 0123'));
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  @override
  Widget build(BuildContext context) {
    final fg = Theme.of(context).colorScheme.onSurface;
    return AuthScaffold(
      title: 'Welcome back',
      subtitle: 'Sign in to your chat account',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuBox(
            inset: true,
            radius: 18,
            blur: 10,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: TextField(
              controller: _email,
              keyboardType: TextInputType.emailAddress,
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                hintText: 'Email',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          NeuBox(
            inset: true,
            radius: 18,
            blur: 10,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextField(
              controller: _password,
              obscureText: _obscure,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                hintText: 'Password',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: fg.withValues(alpha: .6)),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _remember,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _remember = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Text('Remember for 30 days', style: AppText.caption),
            ],
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () => Navigator.of(context).push(_page(ResetScreen(session: widget.session))),
              child: Text(
                'Forgot password?',
                style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 24),
          PillButton(label: 'Sign in', onTap: _signIn),
          const SizedBox(height: 14),
          PillButton(
            label: 'Continue as guest',
            primary: false,
            onTap: () {
              widget.session.signInDemo();
            },
          ),
          const SizedBox(height: 22),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Don't have an account?", style: AppText.caption),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Navigator.of(context).push(_page(SignUpScreen(session: widget.session))),
                child: Text(
                  'Sign up',
                  style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Route<void> _page(Widget screen) => MaterialPageRoute(builder: (_) => screen);
}

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, required this.session});

  final Session session;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;
  bool _agree = false;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _signUp() {
    if (_name.text.trim().isEmpty) return _toast('Please enter your name.');
    if (!_email.text.contains('@')) return _toast('Please enter a valid email.');
    if (_password.text.length < 6) return _toast('Password must be at least 6 characters.');
    if (!_agree) return _toast('Please accept the terms to continue.');
    widget.session.signIn(AppUser(name: _name.text.trim(), email: _email.text.trim(), phone: _phone.text.trim()));
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Create account',
      subtitle: 'Start chatting in seconds',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _field(_name, 'Full name', Icons.person_outline),
          const SizedBox(height: 14),
          _field(_email, 'Email', Icons.mail_outline),
          const SizedBox(height: 14),
          _field(_phone, 'Phone (optional)', Icons.phone_outlined),
          const SizedBox(height: 14),
          NeuBox(
            inset: true,
            radius: 18,
            blur: 10,
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            child: TextField(
              controller: _password,
              obscureText: _obscure,
              cursorColor: AppColors.primary,
              decoration: InputDecoration(
                icon: const Icon(Icons.lock_outline, color: AppColors.primary, size: 20),
                hintText: 'Password',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: .6)),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              SizedBox(
                width: 24,
                height: 24,
                child: Checkbox(
                  value: _agree,
                  activeColor: AppColors.primary,
                  onChanged: (v) => setState(() => _agree = v ?? false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'I agree to the Terms of Service and Privacy Policy',
                  style: AppText.caption,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          PillButton(label: 'Create account', onTap: _signUp),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Already have an account?', style: AppText.caption),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Text(
                  'Sign in',
                  style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, IconData icon) {
    return NeuBox(
      inset: true,
      radius: 18,
      blur: 10,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: TextField(
        controller: c,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          icon: Icon(icon, color: AppColors.primary, size: 20),
          hintText: label,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key, required this.session, this.purpose = 'verify'});

  final Session session;
  final String purpose;

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otp = TextEditingController();

  void _toast(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _submit() {
    final v = _otp.text.trim();
    if (v.isEmpty || v.length < 4) return _toast('Enter the OTP we sent you.');
    widget.session.signInDemo();
  }

  @override
  void dispose() {
    _otp.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Enter OTP',
      subtitle: 'We sent a 6-digit code to you',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          NeuBox(
            inset: true,
            radius: 18,
            blur: 10,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            child: TextField(
              controller: _otp,
              keyboardType: TextInputType.number,
              maxLength: 6,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 24, letterSpacing: 12, fontWeight: FontWeight.w700),
              cursorColor: AppColors.primary,
              decoration: const InputDecoration(
                hintText: '••••••',
                counterText: '',
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          PillButton(label: 'Verify OTP', onTap: _submit),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Didn’t get a code?', style: AppText.caption),
              const SizedBox(width: 4),
              GestureDetector(
                onTap: () {
                  _otp.clear();
                  _toast('OTP resent (demo).');
                },
                child: Text(
                  'Resend',
                  style: AppText.caption.copyWith(color: AppColors.primary, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ResetScreen extends StatefulWidget {
  const ResetScreen({super.key, required this.session});

  final Session session;

  @override
  State<ResetScreen> createState() => _ResetScreenState();
}

class _ResetScreenState extends State<ResetScreen> {
  final _email = TextEditingController(text: 'david@example.com');
  final _code = TextEditingController();
  final _password = TextEditingController();
  int _step = 0;

  void _next() {
    if (_step == 0) {
      if (!_email.text.contains('@')) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid email.')));
        return;
      }
      setState(() => _step = 1);
      return;
    }
    if (_step == 1) {
      if (_code.text.trim().length < 4) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter the code.')));
        return;
      }
      setState(() => _step = 2);
      return;
    }
    if (_password.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password too short.')));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password updated. Sign in with your new password.')),
    );
    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Reset password', 'Enter code', 'New password'];
    final subs = ['We’ll email you a reset code', '6-digit code from your email', 'Choose a new password'];
    return AuthScaffold(
      title: titles[_step],
      subtitle: subs[_step],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_step == 0) _field(_email, 'Email', false),
          if (_step == 1) _field(_code, '6-digit code', true),
          if (_step == 2) _field(_password, 'New password', false),
          const SizedBox(height: 16),
          PillButton(
            label: _step == 2 ? 'Update password' : 'Continue',
            onTap: _next,
          ),
        ],
      ),
    );
  }

  Widget _field(TextEditingController c, String label, bool center) {
    return NeuBox(
      inset: true,
      radius: 18,
      blur: 10,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      child: TextField(
        controller: c,
        obscureText: !center && label == 'New password',
        textAlign: center ? TextAlign.center : TextAlign.start,
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          hintText: label,
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}