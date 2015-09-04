var fs = require('fs')
  , xlsx = require('xlsx')
  , _ = require('underscore')
  , async = require('async')
  , parsers = {}
  , S = require('string')
  , force = require('./force')

parsers.TCPv1 = require('./parsers/tcp1')
parsers.TCPv2 = require('./parsers/tcp2')
parsers.TCPv3 = require('./parsers/TCPv3')
parsers.TCPv4 = require('./parsers/TCPv4')
parsers.GEv1 = require('./parsers/ge')
parsers.GEv2 = require('./parsers/GEv2')
parsers.FEITv1 = require('./parsers/feit')
parsers.PHILIPPSv1 = require('./parsers/PHILIPPSv1')
parsers.PHILIPPSv2 = require('./parsers/PHILIPPSv2')*/
parsers.HOMEDEPOTSUPPLYv1 = require('./parsers/HOMEDEPOTSUPPLYv1')

fs.readdir('../data/spreadsheets/', function(err, files) {

  var xlsFiles = []

  files = _.reject(files, function(fn) {
    return (!S(fn).endsWith('.xls') && !S(fn).endsWith('.xlsx')) || fn.indexOf('~$') > -1
  })

  var result = {};

  _.allKeys(parsers).forEach(function(item) {
    result[item] = []
  })

  var products = {}

  async.each(files, function(fn, cb) {

    console.log(fn)

    var workbook = xlsx.readFile('../data/spreadsheets/' + fn)

    var parserName;
    var parserCount = 0;

    _.allKeys(parsers).forEach(function(item) {
      if(parsers[item].isValid(workbook)) {
        parserName = item;
        parserCount++;
        products[item].push(fn)
      }
    })

    console.log(parserCount + ' : ' + parserName)

    cb()

  }, function(err) {})

  console.log(products)

})
