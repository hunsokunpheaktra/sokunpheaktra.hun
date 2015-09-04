var assert = require('assert'),
  xlsx = require('xlsx'),
  PHILIPPSv1 = require('../parsers/PHILIPPSv1')

var wb1fn = './test/samples/PHILIPPSv1/American Efficient April POS data 2015.xlsx',
  wb2fn = './test/samples/PHILIPPSv1/American Efficient MAR POS DATA 2015.xlsx'

var workbook1 = xlsx.readFile(wb1fn),
  workbook2 = xlsx.readFile(wb2fn)

describe('PHILIPPSv1 Parser', function () {

  describe('Validate', function () {

    it('should validate sample file #1', function () {
      assert.equal(PHILIPPSv1.isValid(workbook1), true);
    })

    it('should validate sample file #2', function () {
      assert.equal(PHILIPPSv1.isValid(workbook2), true);
    })

  })

  describe('Parser', function () {

    it('should get product data from sample file #1', function () {
      var result = PHILIPPSv1.parse(workbook1);

      assert.equal('2015-04-05', result.firstDate);
      assert.equal('2015-04-26', result.lastDate);

      assert.notEqual(result.products['1001004100'], undefined)
      assert.notEqual(result.products['1001004100'].stores['1605'], undefined)
      assert.equal(result.products['1001004100'].manufacturerId, '1001004100');
      assert.equal(result.products['1001004100'].stores['1605'].quantity, 4);
      assert.equal(result.products['1001004100'].stores['1605'].totalPrice, 0.4);

      assert.notEqual(result.products['1000017569'], undefined)
      assert.notEqual(result.products['1000017569'].stores['8981'], undefined)
      assert.equal(result.products['1000017569'].manufacturerId, '1000017569');
      assert.equal(result.products['1000017569'].stores['8981'].quantity, 4);
      assert.equal(result.products['1000017569'].stores['8981'].totalPrice, 0.6);

      assert.notEqual(result.products['1000017765'], undefined)
      assert.notEqual(result.products['1000017765'].stores['3801'], undefined)
      assert.equal(result.products['1000017765'].manufacturerId, '1000017765');
      assert.equal(result.products['1000017765'].stores['3801'].quantity, -2);
      assert.equal(result.products['1000017765'].stores['3801'].totalPrice, -0.2);

      assert.notEqual(result.products['1000999418'], undefined)
      assert.notEqual(result.products['1000999418'].stores['8981'], undefined)
      assert.equal(result.products['1000999418'].manufacturerId, '1000999418');
      assert.equal(result.products['1000999418'].stores['8981'].quantity, -1);
      assert.equal(result.products['1000999418'].stores['8981'].totalPrice, -0.1);
    })

    it('should get product data from sample file #2', function () {
      var result = PHILIPPSv1.parse(workbook2);

      assert.equal('2015-03-01', result.firstDate);
      assert.equal('2015-03-29', result.lastDate);

      result.

      assert.notEqual(result.products['1001004100'], undefined)
      assert.notEqual(result.products['1001004100'].stores['2303'], undefined)
      assert.equal(result.products['1001004100'].manufacturerId, '1001004100');
      assert.equal(result.products['1001004100'].stores['2303'].quantity, 10);
      assert.equal(result.products['1001004100'].stores['2303'].totalPrice, 1);

      assert.notEqual(result.products['1000017569'], undefined)
      assert.notEqual(result.products['1000017569'].stores['8981'], undefined)
      assert.equal(result.products['1000017569'].manufacturerId, '1000017569');
      assert.equal(result.products['1000017569'].stores['8981'].quantity, 4);
      assert.equal(result.products['1000017569'].stores['8981'].totalPrice, 0.6);

      assert.notEqual(result.products['1000999418'], undefined)
      assert.notEqual(result.products['1000999418'].stores['4648'], undefined)
      assert.equal(result.products['1000999418'].manufacturerId, '1000999418');
      assert.equal(result.products['1000999418'].stores['4648'].quantity, -2);
      assert.equal(result.products['1000999418'].stores['4648'].totalPrice, -0.2);
    })

  })

})