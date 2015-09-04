var assert = require('assert')
  , xlsx = require('xlsx')
  , GEv2 = require('../parsers/GEv2')

var wb1fn = './test/samples/GEv2/Wylan VA_Sams_July_POS.xlsx'

var workbook1 = xlsx.readFile(wb1fn)

describe('GEv2 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(GEv2.isValid(workbook1), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = GEv2.parse(workbook1, wb1fn);

      assert.equal(result.month, 6);
      assert.equal(result.year, 2014);

      assert.equal(result.firstDate, '2014-06-27');
      assert.equal(result.lastDate, '2014-07-29');

      assert.notEqual(result.products['28909'], undefined)
      assert.notEqual(result.products['28909'].stores['6518'], undefined)
      assert.equal(result.products['28909'].stores['6518'].quantity, 26);
      assert.equal(result.products['28909'].stores['6518'].lampsPerSku, 3);
      assert.equal(result.products['28909'].stores['6518'].totalPrice, 15.6);

      assert.notEqual(result.products['75925'], undefined)
      assert.notEqual(result.products['75925'].stores['8220'], undefined)
      assert.equal(result.products['75925'].stores['8220'].quantity, 24);
      assert.equal(result.products['75925'].stores['8220'].lampsPerSku, 4);
      assert.equal(result.products['75925'].stores['8220'].totalPrice, 19.2);
    })

  })

})
