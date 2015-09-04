var assert = require('assert')
  , xlsx = require('xlsx')
  , TCPv4 = require('../parsers/TCPv4')

var wb1fn = './test/samples/TCPv4/AEDE-WM POS JUNE 2014.xlsx';

var workbook1 = xlsx.readFile(wb1fn)

describe('TCPv4 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(TCPv4.isValid(workbook1), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {

      var result = TCPv4.parse(workbook1, wb1fn);
      
      assert.equal(result.month, 6);
      assert.equal(result.year, 2014);
      
      assert.equal(result.firstDate, '2014-06-06');
      assert.equal(result.lastDate, '2014-06-27');
      
      assert.notEqual(result.products['GVS14/68914'], undefined)
      assert.notEqual(result.products['GVS14/68914'].stores['1736'], undefined)
      assert.equal(result.products['GVS14/68914'].stores['1736'].quantity, 12);
      assert.equal(result.products['GVS14/68914'].stores['1736'].lampsPerSku, 12);
      assert.equal(result.products['GVS14/68914'].stores['1736'].totalPrice, 2.4);

      assert.notEqual(result.products['GVS194DL/689194DL'], undefined)
      assert.notEqual(result.products['GVS194DL/689194DL'].stores['2555'], undefined)
      assert.equal(result.products['GVS194DL/689194DL'].stores['2555'].quantity, 10);
      assert.equal(result.products['GVS194DL/689194DL'].stores['2555'].lampsPerSku, 40);
      assert.equal(result.products['GVS194DL/689194DL'].stores['2555'].totalPrice, 8.0);
    })
  })
})
