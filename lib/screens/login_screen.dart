import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:loja_virtual/screens/signup_screen.dart';
import 'package:scoped_model/scoped_model.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final emailController = TextEditingController();
  final passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Entrar",),
        centerTitle: true,
        actions: <Widget>[
          FlatButton(
            child: Text(
              "CRIAR CONTA",
              style: TextStyle(
                fontSize: 15.0,
              ),
            ),
            textColor: Colors.white,
            onPressed: () {
              Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) => SignUpScreen(),
                  )
              );
            },
          ),
        ],
      ),
      body: ScopedModelDescendant<UserModel>(
        builder: (context, child, model) {
          if(model.isLoading){
            return Center(child: CircularProgressIndicator(),);
          }

          return Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.all(16.0),
              children: <Widget>[
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                      hintText: "E-mail"
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (text){
                    if(text.isEmpty || !text.contains("@")){
                      return "E-Mail Inválido!";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16.0,),
                TextFormField(
                  controller: passController,
                  decoration: InputDecoration(
                    hintText: "Senha",
                  ),
                  obscureText: true,
                  validator: (text){
                    if(text.isEmpty || text.length < 6){
                      return "Senha inválida!";
                    }
                    return null;
                  },
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: FlatButton(
                    padding: EdgeInsets.zero,
                    onPressed: (){
                      if(emailController.text.isEmpty){
                        _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text("Insira seu E-Mail para recuperação." ),
                              backgroundColor: Colors.red,
                              duration: Duration(seconds: 2),
                            )
                        );
                      }else{
                        model.recoverPass(emailController.text);

                        _scaffoldKey.currentState.showSnackBar(
                            SnackBar(
                              content: Text("Confira seu E-Mail"),
                              backgroundColor: Theme.of(context).primaryColor,
                              duration: Duration(seconds: 2),
                            )
                        );
                      }
                    },
                    child: Text(
                      "Esqueci minha senha",
                      textAlign: TextAlign.right,
                    ),
                  ),
                ),
                SizedBox(height: 16.0,),
                SizedBox(
                  height: 44.0,
                  child: RaisedButton(
                    onPressed: () {
                      if(_formKey.currentState.validate()){
                        model.signIn(
                            email: emailController.text,
                            pass: passController.text,
                            onSuccess: _onSuccess,
                            onFail: _onFail
                        );
                      }
                    },
                    child: Text(
                      "Entrar",
                      style: TextStyle(
                        fontSize: 18.0,
                      ),
                    ),
                    textColor: Colors.white,
                    color: Theme.of(context).primaryColor,
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  void _onSuccess(){
    Navigator.of(context).pop();
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Falha ao entrar!" ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        )
    );
  }

}

