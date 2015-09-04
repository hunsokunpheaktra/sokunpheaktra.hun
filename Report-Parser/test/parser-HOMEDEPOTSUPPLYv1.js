var assert = require('assert')
  , xlsx = require('xlsx')
  , HOMEDEPOTSUPPLYv1 = require('../parsers/HOMEDEPOTSUPPLYv1')

var workbook1 = xlsx.readFile('./test/samples/HOMEDEPOTSUPPLYv1/June Wylan Data Pull.xlsx')
  , workbook2 = xlsx.readFile('./test/samples/HOMEDEPOTSUPPLYv1/July Wylan Data Pull.xlsx')

describe('HOMEDEPOTSUPPLYv1 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(HOMEDEPOTSUPPLYv1.isValid(workbook1), true);
    })

    it('should validate sample file #2', function() {
      assert.equal(HOMEDEPOTSUPPLYv1.isValid(workbook2), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = HOMEDEPOTSUPPLYv1.parse(workbook1);

      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      assert.equal(result.month, 6);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-06-01');
      assert.equal(result.lastDate, '2015-06-30');
      
      assert.notEqual(result.products['109896'], undefined)
      assert.notEqual(result.products['109896'].postalCodes['19607'], undefined)
      assert.equal(result.products['109896'].manufacturerId, '109896');
      assert.equal(result.products['109896'].postalCodes['19607'].quantity, 4);
      assert.equal(result.products['109896'].postalCodes['19607'].totalPrice, 0.2);
      
      assert.notEqual(result.products['109902'], undefined)
      assert.notEqual(result.products['109902'].postalCodes['43017'], undefined)
      assert.equal(result.products['109902'].manufacturerId, '109902');
      assert.equal(result.products['109902'].postalCodes['43017'].quantity, 1);
      assert.equal(result.products['109902'].postalCodes['43017'].totalPrice, 0.65);

    })

    it('should get product data from sample file #2', function() {
      var result = HOMEDEPOTSUPPLYv1.parse(workbook2);

      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      assert.equal(result.month, 7);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-07-01');
      assert.equal(result.lastDate, '2015-07-31');
      
      assert.notEqual(result.products['109895'], undefined)
      assert.notEqual(result.products['109895'].postalCodes['60605'], undefined)
      assert.equal(result.products['109895'].manufacturerId, '109895');
      assert.equal(result.products['109895'].postalCodes['60605'].quantity, 13);
      assert.equal(result.products['109895'].postalCodes['60605'].totalPrice, 0.65);
      
      assert.notEqual(result.products['109900'], undefined)
      assert.notEqual(result.products['109900'].postalCodes['21842'], undefined)
      assert.equal(result.products['109900'].manufacturerId, '109900');
      assert.equal(result.products['109900'].postalCodes['21842'].quantity, 14);
      assert.equal(result.products['109900'].postalCodes['21842'].totalPrice, 9.1);

    })

  })

})
