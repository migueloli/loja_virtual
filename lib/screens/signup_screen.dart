import 'package:flutter/material.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class SignUpScreen extends StatefulWidget {
  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {

  final _formKey = GlobalKey<FormState>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passController = TextEditingController();
  final addressController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
        appBar: AppBar(
          title: Text("Criar Conta",),
          centerTitle: true,
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
                      decoration: InputDecoration(
                          hintText: "Nome Completo"
                      ),
                      validator: (text){
                        if(text.isEmpty){
                          return "Nome Inválido!";
                        }
                        return null;
                      },
                      controller: nameController,
                    ),
                    SizedBox(height: 16.0,),
                    TextFormField(
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
                      controller: emailController,
                    ),
                    SizedBox(height: 16.0,),
                    TextFormField(
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
                      controller: passController,
                    ),
                    SizedBox(height: 16.0,),
                    TextFormField(
                      decoration: InputDecoration(
                        hintText: "Endereço",
                      ),
                      validator: (text){
                        if(text.isEmpty){
                          return "Endereço inválido!";
                        }
                        return null;
                      },
                      controller: addressController,
                    ),
                    SizedBox(height: 16.0,),
                    SizedBox(
                      height: 44.0,
                      child: RaisedButton(
                        onPressed: () {
                          if(_formKey.currentState.validate()){
                            Map<String, dynamic> userData = {
                              "name": nameController.text,
                              "email": emailController.text,
                              "address": addressController.text
                            };

                            model.signUp(
                                userData: userData,
                                pass: passController.text,
                                onSuccess: _onSuccess,
                                onFail: _onFail
                            );
                          }
                        },
                        child: Text(
                          "Criar Conta",
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
            }
        )
    );
  }

  void _onSuccess(){
    _scaffoldKey.currentState.showSnackBar(
      SnackBar(
        content: Text("Usuário criado com sucesso!" ),
        backgroundColor: Theme.of(context).primaryColor,
        duration: Duration(seconds: 2),
      )
    );

    Future.delayed(
      Duration(seconds: 2)
    ).then((_){
      Navigator.of(context).pop();
    });
  }

  void _onFail() {
    _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Falha na criação do usuário!" ),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        )
    );
  }
}
