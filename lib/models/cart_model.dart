import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loja_virtual/datas/cart_product.dart';
import 'package:loja_virtual/models/user_model.dart';
import 'package:scoped_model/scoped_model.dart';

class CartModel extends Model {

  UserModel user;

  List<CartProduct> products = [];
  String couponCode;
  int couponDisc = 0;

  bool isLoading = false;

  static CartModel of(BuildContext context) =>
      ScopedModel.of<CartModel>(context);

  CartModel(this.user){
    if(this.user.isLoggedIn()){
      _loadCartItens();
    }
  }

  void updatePrices(){
    notifyListeners();
  }

  void setCoupon(String coupon, int perc){
    this.couponCode = coupon;
    this.couponDisc = perc;
  }

  void addCartItem(CartProduct product){
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
      .collection("cart").add(product.toMap()).then((doc) {
        product.cid = doc.documentID;
    });

    products.add(product);
    notifyListeners();
  }

  void decProduct(CartProduct product){
    product.quantity--;
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(product.cid).updateData(product.toMap());
    notifyListeners();
  }

  void incProduct(CartProduct product){
    product.quantity++;
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(product.cid).updateData(product.toMap());
    notifyListeners();
  }

  void removeCartItem(CartProduct product){
    Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").document(product.cid).delete();

    products.remove(product);
    notifyListeners();
  }

  void _loadCartItens() async {
    QuerySnapshot query = await Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("cart").getDocuments();

    products = query.documents.map((doc) => CartProduct.fromDocument(doc)).toList();

    notifyListeners();
  }

  double getProductsPrice(){
    double price = 0.0;

    products.forEach((p) {
      if(p.productData != null){
        price += (p.productData.price * p.quantity);
      }
    });

    return price;
  }

  double getDiscount(){
    return (getProductsPrice() * (couponDisc/100)).truncateToDouble();
  }

  double getShipPrice(){
    return 9.99;
  }

  Future<String> finishOrder() async {
    if(products.length == 0) return null;

    isLoading = true;
    notifyListeners();

    double price = getProductsPrice();
    double ship = getShipPrice();
    double disc = getDiscount();

    DocumentReference refOrder = await Firestore.instance.collection("orders").add({
      "clientId" : user.firebaseUser.uid,
      "products" : products.map((cartProdutct) => cartProdutct.toMap()).toList(),
      "shipPrice" : ship,
      "productsPrice" : price,
      "discount" : disc,
      "totalPrice" : price + ship - disc,
      "status" : 1
    });

    await Firestore.instance.collection("users").document(user.firebaseUser.uid)
        .collection("orders").document(refOrder.documentID)
        .setData({"orderId" : refOrder.documentID});

    QuerySnapshot query = await Firestore.instance.collection("users")
        .document(user.firebaseUser.uid).collection("cart").getDocuments();

    query.documents.forEach((doc){
      doc.reference.delete();
    });

    products.clear();
    couponCode = "";
    couponDisc = 0;
    isLoading = false;

    notifyListeners();

    return refOrder.documentID;
  }

}