var express = require('express');
var router = express.Router();

/* GET customers home page. */
router.get('/', function(req, res, next) {
  res.render('entities/customer/index', { title: 'Customers' });
});

module.exports = router;
