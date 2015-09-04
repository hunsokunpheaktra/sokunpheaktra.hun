var assert = require('assert')
  , xlsx = require('xlsx')
  , GEv1 = require('../parsers/ge')

var wb1fn = './test/samples/GEv1/AMERICAN EFFICIENT_April_WALMART_POS.xlsx'
  , wb2fn = './test/samples/GEv1/WYLAN VA_May_AHOLD_POS docx .xlsx'
  , wb3fn = './test/samples/GEv1/WYLAN VA_Feb_TARGET_POS docx (3).xlsx'
  , wb4fn = './test/samples/GEv1/Wylan_Target_March_POS.xlsx'
  , wb5fn = './test/samples/GEv1/WYLAN VA_May_SAMS_POS docx.xlsx'

var workbook1 = xlsx.readFile(wb1fn)
  , workbook2 = xlsx.readFile(wb2fn)
  , workbook3 = xlsx.readFile(wb3fn)
  , workbook4 = xlsx.readFile(wb4fn)
  , workbook5 = xlsx.readFile(wb5fn)

describe('GEv1 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(GEv1.isValid(workbook1), true);
    })

    it('should validate sample file #2', function() {
      assert.equal(GEv1.isValid(workbook2), true);
    })

    it('should validate sample file #3', function() {
      assert.equal(GEv1.isValid(workbook3), true);
    })

    it('should validate sample file #4', function() {
      assert.equal(GEv1.isValid(workbook4), true);
    })

    it('should validate sample file #5', function() {
      assert.equal(GEv1.isValid(workbook5), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = GEv1.parse(workbook1, wb1fn);

      assert.equal(result.month, 3);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-03-16');
      assert.equal(result.lastDate, '2015-04-15');

      assert.notEqual(result.products['68505'], undefined)
      assert.notEqual(result.products['68505'].stores['5039'], undefined)
      assert.equal(result.products['68505'].stores['5039'].quantity, 32);
      assert.equal(result.products['68505'].stores['5039'].lampsPerSku, 3);
      assert.equal(result.products['68505'].stores['5039'].totalPrice, 19.2);

      assert.notEqual(result.products['97728'], undefined)
      assert.notEqual(result.products['97728'].stores['5436'], undefined)
      assert.equal(result.products['97728'].stores['5436'].quantity, 1);
      assert.equal(result.products['97728'].stores['5436'].lampsPerSku, 1);
      assert.equal(result.products['97728'].stores['5436'].totalPrice, 0.2);
    })

    it('should get product data from sample file #2', function() {
      var result = GEv1.parse(workbook2, wb2fn);

      assert.equal(result.month, 5);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-05-01');
      assert.equal(result.lastDate, '2015-05-31');

      assert.notEqual(result.products['42105'], undefined)
      assert.notEqual(result.products['42105'].stores['233'], undefined)
      assert.equal(result.products['42105'].stores['233'].quantity, 9);
      assert.equal(result.products['42105'].stores['233'].lampsPerSku, 2);
      assert.equal(result.products['42105'].stores['233'].totalPrice, 3.6);

      assert.notEqual(result.products['42107'], undefined)
      assert.notEqual(result.products['42107'].stores['770'], undefined)
      assert.equal(result.products['42107'].stores['770'].quantity, 5);
      assert.equal(result.products['42107'].stores['770'].lampsPerSku, 2);
      assert.equal(result.products['42107'].stores['770'].totalPrice, 2);
    })

    it('should get product data from sample file #3', function() {
      var result = GEv1.parse(workbook3, wb3fn);

      assert.equal(result.month, 2);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-02-01');
      assert.equal(result.lastDate, '2015-02-28');

      assert.notEqual(result.products['47452'], undefined)
      assert.notEqual(result.products['47452'].stores['1431'], undefined)
      assert.equal(result.products['47452'].stores['1431'].quantity, 6);
      assert.equal(result.products['47452'].stores['1431'].lampsPerSku, 1);
      assert.equal(result.products['47452'].stores['1431'].totalPrice, 1.2);

      assert.notEqual(result.products['69655'], undefined)
      assert.notEqual(result.products['69655'].stores['1076'], undefined)
      assert.equal(result.products['69655'].stores['1076'].quantity, 60);
      assert.equal(result.products['69655'].stores['1076'].lampsPerSku, 2);
      assert.equal(result.products['69655'].stores['1076'].totalPrice, 24);
    })

    it('should get product data from sample file #4', function() {
      var result = GEv1.parse(workbook4, wb4fn);

      assert.equal(result.month, 3);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-03-01');
      assert.equal(result.lastDate, '2015-04-04');

      assert.notEqual(result.products['47452'], undefined)
      assert.notEqual(result.products['47452'].stores['2501'], undefined)
      assert.equal(result.products['47452'].stores['2501'].quantity, 5);
      assert.equal(result.products['47452'].stores['2501'].lampsPerSku, 1);
      assert.equal(result.products['47452'].stores['2501'].totalPrice, 1);

      assert.notEqual(result.products['47452'], undefined)
      assert.notEqual(result.products['47452'].stores['1009'], undefined)
      assert.equal(result.products['47452'].stores['1009'].quantity, -1);
      assert.equal(result.products['47452'].stores['1009'].lampsPerSku, 1);
      assert.equal(result.products['47452'].stores['1009'].totalPrice, -0.2);

      assert.equal(result.products['24967'], undefined)

      assert.notEqual(result.products['63482'], undefined)
      assert.equal(result.products['63482'].stores['2138'], undefined)
    })

    it('should get product data from sample file #5', function() {
      var result = GEv1.parse(workbook4, wb4fn);

      assert.equal(result.month, 3);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-03-01');
      assert.equal(result.lastDate, '2015-04-04');

      assert.notEqual(result.products['47452'], undefined)
      assert.notEqual(result.products['47452'].stores['2501'], undefined)
      assert.equal(result.products['47452'].stores['2501'].quantity, 5);
      assert.equal(result.products['47452'].stores['2501'].lampsPerSku, 1);
      assert.equal(result.products['47452'].stores['2501'].totalPrice, 1);

      assert.notEqual(result.products['47452'], undefined)
      assert.notEqual(result.products['47452'].stores['1009'], undefined)
      assert.equal(result.products['47452'].stores['1009'].quantity, -1);
      assert.equal(result.products['47452'].stores['1009'].lampsPerSku, 1);
      assert.equal(result.products['47452'].stores['1009'].totalPrice, -0.2);

      assert.equal(result.products['24967'], undefined)

      assert.notEqual(result.products['63482'], undefined)
      assert.equal(result.products['63482'].stores['2138'], undefined)
    })

  })

})
