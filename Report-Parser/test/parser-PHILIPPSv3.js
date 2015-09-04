var assert = require('assert')
  , xlsx = require('xlsx')
  , PHILIPPSv3 = require('../parsers/PHILIPPSv3')

var workbook1 = xlsx.readFile('./test/samples/PHILIPPSv3/American Eff Wylan May POS data 2015.xlsx')

describe('PHILIPPSv3 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(PHILIPPSv3.isValid(workbook1), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = PHILIPPSv3.parse(workbook1);
      
      assert.equal(result.month, 5);
      assert.equal(result.year, 2015);

      assert.equal('2015-05-03', result.firstDate);
      assert.equal('2015-05-24', result.lastDate);

      assert.notEqual(result.products['117476'], undefined)
      assert.notEqual(result.products['117476'].stores['702'], undefined)
      assert.equal(result.products['117476'].manufacturerId, '117476');
      assert.equal(result.products['117476'].stores['702'].quantity, 10);
      assert.equal(result.products['117476'].stores['702'].totalPrice, 4);

      assert.notEqual(result.products['149944'], undefined)
      assert.notEqual(result.products['149944'].stores['1603'], undefined)
      assert.equal(result.products['149944'].manufacturerId, '149944');
      assert.equal(result.products['149944'].stores['1603'].quantity, 2);
      assert.equal(result.products['149944'].stores['1603'].totalPrice, 0.2);

      assert.notEqual(result.products['151785'], undefined)
      assert.notEqual(result.products['151785'].stores['2017'], undefined)
      assert.equal(result.products['151785'].manufacturerId, '151785');
      assert.equal(result.products['151785'].stores['2017'].quantity, 6);
      assert.equal(result.products['151785'].stores['2017'].totalPrice, 0.6);

      assert.notEqual(result.products['446302'], undefined)
      assert.notEqual(result.products['446302'].stores['1608'], undefined)
      assert.equal(result.products['446302'].manufacturerId, '446302');
      assert.equal(result.products['446302'].stores['1608'].quantity, 7);
      assert.equal(result.products['446302'].stores['1608'].totalPrice, 1.75);
    })

  })

})
