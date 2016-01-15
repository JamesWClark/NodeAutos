var express = require('express');
var router = express.Router();

/* GET sales home page. */
router.get('/', function(req, res, next) {
  res.render('entities/sale/index', { title: 'Sales' });
});

module.exports = router;
