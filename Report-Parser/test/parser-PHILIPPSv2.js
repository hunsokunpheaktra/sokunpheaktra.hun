var assert = require('assert')
  , xlsx = require('xlsx')
  , PHILIPPSv2 = require('../parsers/PHILIPPSv2')

var workbook1 = xlsx.readFile('./test/samples/PHILIPPSv2/BLS_Wylan Energy POS 9.27.14.xlsx')
, workbook2 = xlsx.readFile('./test/samples/PHILIPPSv2/Wylan_BLS_POS Weekending 11.29.14 .xlsx')

describe('PHILIPPSv2 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(PHILIPPSv2.isValid(workbook1), true);
    })
    
    it('should validate sample file #2', function() {
      assert.equal(PHILIPPSv2.isValid(workbook2), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = PHILIPPSv2.parse(workbook1);

      assert.equal('2014-08-31', result.firstDate);
      assert.equal('2014-09-27', result.lastDate);

      assert.notEqual(result.products['250007762'], undefined)
      assert.equal(result.products['250007762'].manufacturerId, '250007762');
      assert.notEqual(result.products['250007762'].stores['1561'], undefined)
      assert.equal(result.products['250007762'].stores['1561'].quantity, 3);
      assert.equal(result.products['250007762'].stores['1561'].totalPrice, 2.24);

      assert.notEqual(result.products['250007765'], undefined)
      assert.equal(result.products['250007765'].manufacturerId, '250007765');
      assert.notEqual(result.products['250007765'].stores['5114'], undefined)
      assert.equal(result.products['250007765'].stores['5114'].quantity, 4);
      assert.equal(result.products['250007765'].stores['5114'].totalPrice, 3.2);

      assert.notEqual(result.products['250007344'], undefined)
      assert.equal(result.products['250007344'].manufacturerId, '250007344');
      assert.notEqual(result.products['250007344'].stores['1400'], undefined)
      assert.equal(result.products['250007344'].stores['1400'].quantity, 2);
      assert.equal(result.products['250007344'].stores['1400'].totalPrice, 1.6);

    })
    
    it('should get product data from sample file #2', function() {
      var result = PHILIPPSv2.parse(workbook2);

      assert.equal('2014-10-26', result.firstDate);
      assert.equal('2014-11-29', result.lastDate);

      assert.notEqual(result.products['250007850'], undefined)
      assert.equal(result.products['250007850'].manufacturerId, '250007850');
      assert.notEqual(result.products['250007850'].stores['1997'], undefined)
      assert.equal(result.products['250007850'].stores['1997'].quantity, 2);
      assert.equal(result.products['250007850'].stores['1997'].totalPrice, 0.64);

      assert.notEqual(result.products['250007852'], undefined)
      assert.equal(result.products['250007852'].manufacturerId, '250007852');
      assert.notEqual(result.products['250007852'].stores['1400'], undefined)
      assert.equal(result.products['250007852'].stores['1400'].quantity, 3);
      assert.equal(result.products['250007852'].stores['1400'].totalPrice, 0.36);

      assert.notEqual(result.products['250007343'], undefined)
      assert.equal(result.products['250007343'].manufacturerId, '250007343');
      assert.notEqual(result.products['250007343'].stores['5114'], undefined)
      assert.equal(result.products['250007343'].stores['5114'].quantity, 7);
      assert.equal(result.products['250007343'].stores['5114'].totalPrice, 4.48);

    })

  })

});
