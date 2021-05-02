const express = require("express");
const bodyParser = require("body-parser");
const firebase = require("firebase/app");
const compression = require("compression");
require("firebase/auth");
var flash = require("connect-flash");
var serviceAccount = require("./serviceAccountKey.json");
const requireLogin = require("./middlewares/requirelogin");
const admin = require("firebase-admin");
require("firebase/database");
require('firebase/app');
var firebaseConfig = require("./keys");
app = express();
app.use(express.static("public"));

app.use(flash());

app.set("view engine", "ejs");
app.use(bodyParser.urlencoded({ extended: true }));

app.use(compression());

var firebaseConfig = {
  apiKey: "AIzaSyAXSggMVI-LRdgkbx18r0WVofx5H1sqjxE",
  authDomain: "saathixebia.firebaseapp.com",
  databaseURL: "https://saathixebia-default-rtdb.firebaseio.com",
  projectId: "saathixebia",
  storageBucket: "saathixebia.appspot.com",
  messagingSenderId: "113048517755",
  appId: "1:113048517755:web:282535773f653a33e5b6de",
};

firebase.initializeApp(firebaseConfig);

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://saathixebia-default-rtdb.firebaseio.com"
});

app.get("/", (req, res) => {
  res.render("login");
});

app.post("/", (req, res) => {
  var email = req.body.email;
  var password = req.body.password;
  firebase
    .auth()
    .signInWithEmailAndPassword(email, password)
    .then(() => {
      res.redirect("/dashboard");
    })
    .catch((err) => res.redirect("/register"));
});


app.get("/register", (req, res) => {
  res.render("register");
});

app.post("/register", (req, res) => {
  var email = req.body.email;
  var password = req.body.password;
  admin
  .auth()
  .createUser({
    email: email,
    password: password,
  })
  res.redirect("/");
});


app.get("/dashboard", (req, res) => {
  var device = firebase.database().ref("QR Codes");
  device.once("value", (data) => {
    if (data.val()) {
      var dev_values = data.val();
      var dev_list = Object.getOwnPropertyNames(data.val());
      var parents = firebase.database().ref("Parents");
      parents.once("value", (data) => {
        var parent_val = data.val();
        var parent_list = Object.getOwnPropertyNames(data.val());
        res.render("main_dashboard", {
          devices: dev_list,
          data: dev_values,
          par_list: parent_list,
          par_val: parent_val,
        });
      });
    }
  });
});

app.get("/user/:eachParent", (req, res) => {
  const userId = req.params.eachParent;
  var parents = firebase.database().ref("Parents");
  parents.once("value", (data) => {
    var parent_val = data.val();
    var parent_list = Object.getOwnPropertyNames(data.val());
    res.render("user", {
      userId: userId,
      par_list: parent_list,
      par_val: parent_val,
    });
  });
});

app.get("/device", (req, res) => {
  res.render("device");
});

app.post("/device", (req, res) => {
  var device = req.body.dev_id;
  var rootRef = firebase.database().ref().child("QR Codes");
  var root2 = rootRef.child(device);
  var userData = {
    Emergency: false,
    Location: {
      0: "Departed",
    },
  };
  root2.set(userData);
  res.redirect("/device");
});

const port = process.env.PORT || 8000;
app.listen(port, () => console.log(`Server started at port ${port}`));
