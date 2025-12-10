import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  String? erroLogin;

  bool _isLogin = true;
  bool loading = false;

  final String backendUrl = "http://localhost:8000/auth";

  // ---------------------------
  // FUNÇÕES FICAM AQUI DENTRO ⬇️
  // ---------------------------

  Future<void> fazerCadastro() async {
    setState(() => loading = true);

    final body = {
      "nome": _nameController.text,
      "email": _emailController.text,
      "senha": _passwordController.text,
    };

    final resp = await http.post(
      Uri.parse("$backendUrl/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    setState(() => loading = false);

    if (resp.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso!")),
      );

      setState(() => _isLogin = true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro: ${resp.body}")),
      );
    }
  }

  Future<void> fazerLogin() async {
    setState(() { 
    loading = true;
    erroLogin=null;
  });

    final body = {
      "email": _emailController.text,
      "senha": _passwordController.text,
    };

    final resp = await http.post(
      Uri.parse("$backendUrl/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode(body),
    );

    setState(() => loading = false);

    if (resp.statusCode == 200) {
      final json = jsonDecode(resp.body);
      final token = json["access_token"];

      // salvar token no SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString("token", token);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } else {
      setState(() {
        erroLogin = "Usuário ou senha incorreto";
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _isLogin ? 'UrbanFlow Login' : 'Crie sua conta',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                    ),
                    const SizedBox(height: 24),
                    if (!_isLogin)
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Completo',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? 'Informe seu nome' : null,
                      ),
                    if (!_isLogin) const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: 'E-mail',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          !value!.contains('@') ? 'E-mail inválido' : null,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Senha',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) => value!.length < 6
                          ? 'A senha deve ter pelo menos 6 caracteres'
                          : null,
                    ),
                    const SizedBox(height: 24),
                    if (erroLogin != null) 
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                        erroLogin!,
                        style: const TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLogin ? fazerLogin : fazerCadastro,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          _isLogin ? 'ENTRAR' : 'CADASTRAR',
                          style: const TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isLogin = !_isLogin;
                        });
                      },
                      child: Text(
                        _isLogin
                            ? 'Não tem conta? Cadastre-se'
                            : 'Já tem conta? Faça login',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}