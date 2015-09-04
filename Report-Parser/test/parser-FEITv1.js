var assert = require('assert')
  , xlsx = require('xlsx')
  , FEITv1 = require('../parsers/feit')

var workbook1 = xlsx.readFile('./test/samples/FEITv1/Costco_WEDE Sales Data 3.30.15-4.26.15.xlsx')
  , workbook2 = xlsx.readFile('./test/samples/FEITv1/Costco_WEVA Sales Data 3.30.15-4.26.15 - Copy.xlsx')
  , workbook3 = xlsx.readFile('./test/samples/FEITv1/Costco_Wylan Energy Virginia Sales Data 12.1.14-1.4.15.xlsx')
  , workbook4 = xlsx.readFile('./test/samples/FEITv1/Costco_WEVA Sales Data 3.2.15-3.29.15.xlsx')

describe('FEITv1 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(FEITv1.isValid(workbook1), true);
    })

    it('should validate sample file #2', function() {
      assert.equal(FEITv1.isValid(workbook2), true);
    })

    it('should validate sample file #3', function() {
      assert.equal(FEITv1.isValid(workbook3), true);
    })

    it('should validate sample file #4', function() {
      assert.equal(FEITv1.isValid(workbook4), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = FEITv1.parse(workbook1);

      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      assert.equal(result.month, 4);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-04-05');
      assert.equal(result.lastDate, '2015-04-26');

      assert.notEqual(result.products['107644'], undefined)
      assert.notEqual(result.products['107644'].stores['246'], undefined)
      assert.equal(result.products['107644'].manufacturerId, '107644');
      assert.equal(result.products['107644'].description1, '739151');
      assert.equal(result.products['107644'].description2, 'CE23T2/6');
      assert.equal(result.products['107644'].stores['246'].quantity, 150);
      assert.equal(result.products['107644'].stores['246'].lampsPerSku, 6);
      assert.equal(result.products['107644'].stores['246'].totalPrice, 300);

    })

    it('should get product data from sample file #2', function() {
      var result = FEITv1.parse(workbook2);

      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      assert.equal(result.month, 4);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-04-05');
      assert.equal(result.lastDate, '2015-04-26');

      assert.notEqual(result.products['107645'], undefined)
      assert.notEqual(result.products['107645'].stores['202'], undefined)
      assert.equal(result.products['107645'].manufacturerId, '107645');
      assert.equal(result.products['107645'].description1, '739151');
      assert.equal(result.products['107645'].description2, 'CE23T2/6');
      assert.equal(result.products['107645'].stores['202'].quantity, 144);
      assert.equal(result.products['107645'].stores['202'].lampsPerSku, 6);
      assert.equal(result.products['107645'].stores['202'].totalPrice, 288);

      assert.notEqual(result.products['107645'], undefined)
      assert.notEqual(result.products['107645'].stores['1115'], undefined)
      assert.equal(result.products['107645'].manufacturerId, '107645');
      assert.equal(result.products['107645'].description1, '739151');
      assert.equal(result.products['107645'].description2, 'CE23T2/6');
      assert.equal(result.products['107645'].stores['1115'].quantity, 96);
      assert.equal(result.products['107645'].stores['1115'].lampsPerSku, 6);
      assert.equal(result.products['107645'].stores['1115'].totalPrice, 192);
    })

    it('should get product data from sample file #3', function() {
      var result = FEITv1.parse(workbook3);

      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      assert.equal(result.month, 1);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2014-12-07');
      assert.equal(result.lastDate, '2015-01-04');

      assert.notEqual(result.products['107645'], undefined)
      assert.notEqual(result.products['107645'].stores['204'], undefined)
      assert.equal(result.products['107645'].manufacturerId, '107645');
      assert.equal(result.products['107645'].description1, '739151');
      assert.equal(result.products['107645'].description2, 'CE23T2/6');
      assert.equal(result.products['107645'].stores['204'].quantity, 425);
      assert.equal(result.products['107645'].stores['204'].lampsPerSku, 6);
      assert.equal(result.products['107645'].stores['204'].totalPrice, 850);

      assert.notEqual(result.products['107645'], undefined)
      assert.notEqual(result.products['107645'].stores['626'], undefined)
      assert.equal(result.products['107645'].manufacturerId, '107645');
      assert.equal(result.products['107645'].description1, '739151');
      assert.equal(result.products['107645'].description2, 'CE23T2/6');
      assert.equal(result.products['107645'].stores['626'].quantity, 226);
      assert.equal(result.products['107645'].stores['626'].lampsPerSku, 6);
      assert.equal(result.products['107645'].stores['626'].totalPrice, 452);
    })

    it('should get product data from sample file #4', function() {
      var result = FEITv1.parse(workbook4);

      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      assert.equal(result.month, 3);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-03-08');
      assert.equal(result.lastDate, '2015-03-29');

      assert.notEqual(result.products['107645'], undefined)
      assert.notEqual(result.products['107645'].stores['204'], undefined)
      assert.equal(result.products['107645'].manufacturerId, '107645');
      assert.equal(result.products['107645'].description1, '739151');
      assert.equal(result.products['107645'].description2, 'CE23T2/6');
      assert.equal(result.products['107645'].stores['204'].quantity, 393);
      assert.equal(result.products['107645'].stores['204'].lampsPerSku, 6);
      assert.equal(result.products['107645'].stores['204'].totalPrice, 786);

      assert.notEqual(result.products['107645'], undefined)
      assert.notEqual(result.products['107645'].stores['1115'], undefined)
      assert.equal(result.products['107645'].manufacturerId, '107645');
      assert.equal(result.products['107645'].description1, '739151');
      assert.equal(result.products['107645'].description2, 'CE23T2/6');
      assert.equal(result.products['107645'].stores['1115'].quantity, 104);
      assert.equal(result.products['107645'].stores['1115'].lampsPerSku, 6);
      assert.equal(result.products['107645'].stores['1115'].totalPrice, 208);
    })


  })

})
