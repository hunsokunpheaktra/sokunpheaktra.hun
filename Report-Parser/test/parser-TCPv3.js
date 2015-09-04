var assert = require('assert')
  , xlsx = require('xlsx')
  , TCPv3 = require('../parsers/TCPv3')

var wb1fn = './test/samples/TCPv3/2014 VIRGINIA (WYLAN) WEEKLY SALES FILE 12.21.14.xlsx';

var workbook1 = xlsx.readFile(wb1fn)

describe('TCPv3 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(TCPv3.isValid(workbook1), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {

      var result = TCPv3.parse(workbook1, wb1fn);

      assert.equal(result.month, 12);
      assert.equal(result.year, 2014);

      assert.equal(result.firstDate, '2014-12-14');
      assert.equal(result.lastDate, '2014-12-21');

      assert.notEqual(result.products['1000-019-042'], undefined)
      assert.notEqual(result.products['1000-019-042'].stores['4605'], undefined)
      assert.equal(result.products['1000-019-042'].stores['4605'].quantity, 11);
      assert.equal(result.products['1000-019-042'].stores['4605'].lampsPerSku, 4);
      assert.equal(result.products['1000-019-042'].stores['4605'].totalPrice, 8.8);

      assert.notEqual(result.products['1000-019-048'], undefined)
      assert.notEqual(result.products['1000-019-048'].stores['4654'], undefined)
      assert.equal(result.products['1000-019-048'].stores['4654'].quantity, -1);
      assert.equal(result.products['1000-019-048'].stores['4654'].lampsPerSku, 4);
      assert.equal(result.products['1000-019-048'].stores['4654'].totalPrice, -0.8);
    })
  })
})
