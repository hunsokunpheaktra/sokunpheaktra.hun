var assert = require('assert')
  , xlsx = require('xlsx')
  , TCPv1 = require('../parsers/tcp1')

var workbook1 = xlsx.readFile('./test/samples/TCPv1/AEDE-WM POS WE 4.10.xlsx')
  , workbook2 = xlsx.readFile('./test/samples/TCPv1/WYLANVA-WM POS WE 4.10.xlsx')
  , workbook3 = xlsx.readFile('./test/samples/TCPv1/AEDE-WM POS WE 7.25.xlsx')
  , workbook4 = xlsx.readFile('./test/samples/TCPv1/WYLAN VA-WM POS WE 1.2.xlsx')

describe('TCPv1 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(TCPv1.isValid(workbook1), true);
    })

    it('should validate sample file #2', function() {
      assert.equal(TCPv1.isValid(workbook2), true);
    })

    it('should validate sample file #3', function() {
      assert.equal(TCPv1.isValid(workbook3), true);
    })

    it('should validate sample file #4', function() {
      assert.equal(TCPv1.isValid(workbook4), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = TCPv1.parse(workbook1);

      assert.equal(result.month, 4);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-04-04');
      assert.equal(result.lastDate, '2015-04-10');

      assert.notEqual(result.products['GVS144/689144'], undefined)
      assert.notEqual(result.products['GVS144/689144'].stores['1736'], undefined)
      assert.equal(result.products['GVS144/689144'].stores['1736'].quantity, 27);
      assert.equal(result.products['GVS144/689144'].stores['1736'].lampsPerSku, 108);
      assert.equal(result.products['GVS144/689144'].stores['1736'].totalPrice, 21.6);

      assert.notEqual(result.products['GVR3142DL/6R30142DL'], undefined)
      assert.notEqual(result.products['GVR3142DL/6R30142DL'].stores['2555'], undefined)
      assert.equal(result.products['GVR3142DL/6R30142DL'].stores['2555'].quantity, 2);
      assert.equal(result.products['GVR3142DL/6R30142DL'].stores['2555'].lampsPerSku, 4);
      assert.equal(result.products['GVR3142DL/6R30142DL'].stores['2555'].totalPrice, 0.8);
    })

    it('should get product data from sample file #2', function() {
      var result = TCPv1.parse(workbook2);

      assert.equal(result.month, 4);
      assert.equal(result.year, 2015);

      assert.equal(result.firstDate, '2015-04-04');
      assert.equal(result.lastDate, '2015-04-10');

      assert.notEqual(result.products['GVS094/689094'], undefined)
      assert.notEqual(result.products['GVS094/689094'].stores['5880'], undefined)
      assert.equal(result.products['GVS094/689094'].stores['5880'].quantity, 4);
      assert.equal(result.products['GVS094/689094'].stores['5880'].lampsPerSku, 16);
      assert.equal(result.products['GVS094/689094'].stores['5880'].totalPrice, 3.20);

      assert.notEqual(result.products['GVD09C3DL/69709C3DL'], undefined)
      assert.notEqual(result.products['GVD09C3DL/69709C3DL'].stores['3831'], undefined)
      assert.equal(result.products['GVD09C3DL/69709C3DL'].stores['3831'].quantity, 2);
      assert.equal(result.products['GVD09C3DL/69709C3DL'].stores['3831'].lampsPerSku, 6);
      assert.equal(result.products['GVD09C3DL/69709C3DL'].stores['3831'].totalPrice, 1.20);
    })

    it('should get product data from sample file #3', function() {
      var result = TCPv1.parse(workbook3);

      assert.equal(result.month, 7);
      assert.equal(result.year, 2014);

      assert.equal(result.firstDate, '2014-07-19');
      assert.equal(result.lastDate, '2014-07-25');

      assert.notEqual(result.products['GVS14/68914'], undefined)
      assert.notEqual(result.products['GVS14/68914'].stores['5436'], undefined)
      assert.equal(result.products['GVS14/68914'].stores['5436'].quantity, 2);
      assert.equal(result.products['GVS14/68914'].stores['5436'].lampsPerSku, 2);
      assert.equal(result.products['GVS14/68914'].stores['5436'].totalPrice, 0.4);

      assert.notEqual(result.products['GVD093/697093'], undefined)
      assert.notEqual(result.products['GVD093/697093'].stores['1741'], undefined)
      assert.equal(result.products['GVD093/697093'].stores['1741'].quantity, 2);
      assert.equal(result.products['GVD093/697093'].stores['1741'].lampsPerSku, 6);
      assert.equal(result.products['GVD093/697093'].stores['1741'].totalPrice, 1.20);
    })

    it('should get product data from sample file #4', function() {
      var result = TCPv1.parse(workbook4);

      assert.equal(result.month, 12);
      assert.equal(result.year, 2014);

      assert.equal(result.firstDate, '2014-12-27');
      assert.equal(result.lastDate, '2015-01-02');

      assert.notEqual(result.products['GVS14/68914'], undefined)
      assert.notEqual(result.products['GVS14/68914'].stores['1345'], undefined)
      assert.equal(result.products['GVS14/68914'].stores['1345'].quantity, 10);
      assert.equal(result.products['GVS14/68914'].stores['1345'].lampsPerSku, 10);
      assert.equal(result.products['GVS14/68914'].stores['1345'].totalPrice, 2);
    })

  })

})
