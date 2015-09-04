var assert = require('assert')
  , xlsx = require('xlsx')
  , TCPv2 = require('../parsers/tcp2')

var workbook1 = xlsx.readFile('./test/samples/TCPv2/2015 DELAWARE (WYLAN) WEEKLY SALES FILE 4.12.15.xls')
  , workbook2 = xlsx.readFile('./test/samples/TCPv2/Wylan Energy VA_Wylan Energy_The Home Depot_WYVATHD 2014_20150510_2856071.xls')

describe('TCPv2 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(TCPv2.isValid(workbook1), true);
    })

    it('should validate sample file #2', function() {
      assert.equal(TCPv2.isValid(workbook2), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {

      var result = TCPv2.parse(workbook1);

      assert.equal(result.month, 4);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-04-05');
      assert.equal(result.lastDate, '2015-04-12');

      assert.notEqual(result.products['ES9M814TS4'], undefined)
      assert.notEqual(result.products['ES9M814TS4'].stores['8440'], undefined)
      assert.equal(result.products['ES9M814TS4'].stores['8440'].quantity, 2);
      assert.equal(result.products['ES9M814TS4'].stores['8440'].lampsPerSku, 8);
      assert.equal(result.products['ES9M814TS4'].stores['8440'].totalPrice, 1.6);

      assert.notEqual(result.products['ES9M823435K'], undefined)
      assert.notEqual(result.products['ES9M823435K'].stores['1605'], undefined)
      assert.equal(result.products['ES9M823435K'].stores['1605'].quantity, 6);
      assert.equal(result.products['ES9M823435K'].stores['1605'].lampsPerSku, 24);
      assert.equal(result.products['ES9M823435K'].stores['1605'].totalPrice, 4.80);
    })

    it('should get product data from sample file #2', function() {

      var result = TCPv2.parse(workbook2);

      assert.equal(result.month, 5);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-05-03');
      assert.equal(result.lastDate, '2015-05-10');

      assert.notEqual(result.products['ES59032'], undefined)
      assert.notEqual(result.products['ES59032'].stores['4608'], undefined)
      assert.equal(result.products['ES59032'].stores['4608'].quantity, -2);
      assert.equal(result.products['ES59032'].stores['4608'].lampsPerSku, -2);
      assert.equal(result.products['ES59032'].stores['4608'].totalPrice, -0.40);

      assert.notEqual(result.products['ES9A8142IB'], undefined)
      assert.notEqual(result.products['ES9A8142IB'].stores['8551'], undefined)
      assert.equal(result.products['ES9A8142IB'].stores['8551'].quantity, 2);
      assert.equal(result.products['ES9A8142IB'].stores['8551'].lampsPerSku, 4);
      assert.equal(result.products['ES9A8142IB'].stores['8551'].totalPrice, 0.8);
    })

  })

})
