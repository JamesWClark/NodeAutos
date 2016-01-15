var sqliteFileName = "AutosDB.sqlite";

var express = require('express');
var sqlite3 = require("sqlite3");
var TransactionDatabase = require("sqlite3-transactions").TransactionDatabase;
var router = express.Router();
var engine = new sqlite3.Database(sqliteFileName, sqlite3.OPEN_READWRITE | sqlite3.OPEN_CREATE);
var db = new TransactionDatabase(engine);

engine.exec("PRAGMA foreign_keys = ON");

/* GET all dealerships - home page. */
router.get('/', function(req, res, next) {
  db.all("SELECT * FROM Dealership", function(err,rows){
    console.log('dealership rows fetched: ' + rows.length);
    res.render('entities/dealership/index', { title: 'Dealerships', data: rows });
  });
});

/* GET one dealership and address */
router.get('/:id', function(req,res,next) {
  var id = req.params.id;
  db.all("SELECT * " +
         "FROM Dealership JOIN Address ON Dealership.AddressID = Address.ID " +
         "WHERE Dealership.ID = " + id, 
  function(err, rows) {
    console.log('one dealership fetched, id = ' + id);
    res.render('entities/dealership/update', { title: rows[0].Owner, data: rows[0] });
  });
});

/* GET form - create dealership */
router.get('/forms/create', function(req,res,next) {
  res.render('entities/dealership/create', { title: 'New Dealership' });
});

/* GET form - edit dealership */
router.get('/forms/edit/:id', function(req,res,next) {
  var id = req.params.id;
  db.all("SELECT * " + 
         "FROM Dealership JOIN Address ON Dealership.AddressID = Address.ID " +
         "WHERE Dealership.ID = " + id, 
         
  function(err,rows) {
    console.log('fetch dealership with id = ' + id + ', found: ' + rows.length);
    res.render('entities/dealership/edit', { title: 'Edit Dealership', data: rows[0] });
  });
});

/* POST new Dealership */
router.post('/', function(req,res,next){
  var data = req.body;

  // Begin a transaction.
  // http://stackoverflow.com/questions/28803520/does-sqlite3-have-prepared-statements-in-node-js
  db.beginTransaction(function(err, transaction) {
    // Now we are inside a transaction.
    // Use transaction as normal sqlite3.Database object.
    transaction.run(
      "INSERT INTO Address(Street, City, State, Zip, Country) " + 
      "VALUES(?,?,?,?,?)",
      data.Street,
      data.City,
      data.State,
      data.Zip,
      data.Country
    );
    
    transaction.run(
      "INSERT INTO Dealership(AddressID, Owner, Label) " +
      "VALUES(last_insert_rowid(),?,?)",
      data.Owner,
      data.Label
    );

    transaction.commit(function(err) {
      if(err)
        console.log('commit fail');
      else
        console.log('commit success');
    });    
  });
  
  res.send(req.body);
});

router.post('/edit', function(req,res,next) {
  var data = req.body;
  console.log('received update request on dealership\n--------------------------');
  console.log('id = ' + data.id);
  
  // Begin a transaction.
  // http://stackoverflow.com/questions/28803520/does-sqlite3-have-prepared-statements-in-node-js
  db.beginTransaction(function(err, transaction) {
    // Now we are inside a transaction.
    // Use transaction as normal sqlite3.Database object.
    transaction.run(
      "UPDATE Address " +
      "SET Street = ?, City = ?, State = ?, Zip = ?, Country = ? " + 
      "WHERE ID = " + data.AddressID,
      data.Street,
      data.City,
      data.State,
      data.Zip,
      data.Country
    );
    
    transaction.run(
      "UPDATE Dealership " +
      "SET Owner = ?, Label = ? " +
      "WHERE ID = " + data.ID,
      data.Owner,
      data.Label
    );

    transaction.commit(function(err) {
      if(err)
        console.log('commit fail');
      else
        console.log('commit success');
    });    
  });
  
  res.redirect('/dealerships');
});

module.exports = router;
