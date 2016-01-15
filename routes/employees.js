var express = require('express');
var router = express.Router();

/* GET employees home page. */
router.get('/', function(req, res, next) {
  res.render('entities/employee/index', { title: 'Employees' });
});

module.exports = router;
