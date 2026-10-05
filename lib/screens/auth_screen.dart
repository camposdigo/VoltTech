import 'package:flutter/material.dart';

import '../controllers/volttech_store.dart';
import '../services/supabase_service.dart';
import '../widgets/common.dart';

Future<bool> requireLogin(BuildContext context) async {
  if (VoltTechStore.instance.signedIn) return true;
  await Navigator.of(context)
      .push(MaterialPageRoute(builder: (_) => const AuthScreen()));
  return VoltTechStore.instance.signedIn;
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController(),
      password = TextEditingController(),
      name = TextEditingController();
  bool register = false, busy = false, visible = false;
  String? error;
  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!form.currentState!.validate()) return;
    setState(() {
      busy = true;
      error = null;
    });
    try {
      final auth = SupabaseService.instance.client.auth;
      if (register) {
        final result = await auth.signUp(
          email: email.text.trim(),
          password: password.text,
          data: {'name': name.text.trim()},
        );
        if (result.session == null) {
          if (mounted) {
            setState(() => register = false);
            message(
              context,
              'Confira seu e-mail para confirmar o cadastro. Depois entre com sua senha.',
            );
          }
          return;
        }
      } else {
        await auth.signInWithPassword(
          email: email.text.trim(),
          password: password.text,
        );
      }
      await VoltTechStore.instance.loadUser();
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (mounted) setState(() => error = friendlyError(e));
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(register ? 'Criar conta' : 'Entrar')),
    body: PageBody(
      maxWidth: 480,
      children: [
        const Icon(Icons.bolt, size: 48),
        SectionTitle(
          register
              ? 'Sua próxima escolha começa aqui.'
              : 'Que bom ter você por aqui.',
          'Salve seus favoritos e acompanhe suas compras.',
        ),
        Form(
          key: form,
          child: Column(
            children: [
              if (register) ...[
                TextFormField(
                  controller: name,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [AutofillHints.name],
                  decoration: const InputDecoration(labelText: 'Seu nome'),
                  validator: (v) =>
                      v!.trim().length < 2 ? 'Informe seu nome' : null,
                ),
                const SizedBox(height: 16),
              ],
              TextFormField(
                controller: email,
                keyboardType: TextInputType.emailAddress,
                autofillHints: const [AutofillHints.email],
                decoration: const InputDecoration(labelText: 'E-mail'),
                validator: (v) =>
                    RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(v!.trim())
                    ? null
                    : 'Informe um e-mail válido',
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: password,
                obscureText: !visible,
                onFieldSubmitted: (_) => busy ? null : submit(),
                decoration: InputDecoration(
                  labelText: 'Senha',
                  helperText: register ? 'Use pelo menos 8 caracteres.' : null,
                  suffixIcon: IconButton(
                    tooltip: visible ? 'Ocultar senha' : 'Mostrar senha',
                    onPressed: () => setState(() => visible = !visible),
                    icon: Icon(
                      visible ? Icons.visibility_off : Icons.visibility,
                    ),
                  ),
                ),
                validator: (v) =>
                    v!.length < (register ? 8 : 1) ? 'Confira sua senha' : null,
              ),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.orangeAccent),
                  ),
                ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: busy ? null : submit,
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Text(
                      busy
                          ? 'Aguarde…'
                          : register
                          ? 'Criar minha conta'
                          : 'Entrar',
                    ),
                  ),
                ),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => setState(() {
                        register = !register;
                        error = null;
                      }),
                child: Text(
                  register ? 'Já tenho conta' : 'Ainda não tenho conta',
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
