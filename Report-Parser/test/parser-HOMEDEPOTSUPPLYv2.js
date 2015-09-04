var assert = require('assert')
  , xlsx = require('xlsx')
  , HOMEDEPOTSUPPLYv2 = require('../parsers/HOMEDEPOTSUPPLYv2')

var workbook1 = xlsx.readFile('./test/samples/HOMEDEPOTSUPPLYv2/Wylan Historic Pull 2011 - May 2015.xlsx');

describe('HOMEDEPOTSUPPLYv2 Parser', function(){

  describe('Validate', function(){

    it('should validate sample file #1', function() {
      assert.equal(HOMEDEPOTSUPPLYv2.isValid(workbook1), true);
    })

  })

  describe('Parser', function(){

    it('should get product data from sample file #1', function() {
      var result = HOMEDEPOTSUPPLYv2.parse(workbook1);
      
      assert.notEqual(undefined, result, 'Cannot parse file provided - invalid format.');

      //2011 data assert
      assert.equal(result['2011-12-01_2011-12-31'].month, 12);
      assert.equal(result['2011-12-01_2011-12-31'].year, 2011);
      assert.equal(result['2011-12-01_2011-12-31'].firstDate, '2011-12-01');
      assert.equal(result['2011-12-01_2011-12-31'].lastDate, '2011-12-31');
      
      assert.notEqual(result['2011-12-01_2011-12-31'].products['306914'], undefined)
      assert.notEqual(result['2011-12-01_2011-12-31'].products['306914'].postalCodes['07090'], undefined)
      assert.equal(result['2011-12-01_2011-12-31'].products['306914'].manufacturerId, '306914');
      assert.equal(result['2011-12-01_2011-12-31'].products['306914'].postalCodes['07090'].quantity, 6);
      
      //2012 data assert
      assert.equal(result['2012-01-01_2012-01-31'].month, 1);
      assert.equal(result['2012-01-01_2012-01-31'].year, 2012);
      assert.equal(result['2012-01-01_2012-01-31'].firstDate, '2012-01-01');
      assert.equal(result['2012-01-01_2012-01-31'].lastDate, '2012-01-31');
      
      assert.notEqual(result['2012-01-01_2012-01-31'].products['306013'], undefined)
      assert.notEqual(result['2012-01-01_2012-01-31'].products['306013'].postalCodes['08534'], undefined)
      assert.equal(result['2012-01-01_2012-01-31'].products['306013'].manufacturerId, '306013');
      assert.equal(result['2012-01-01_2012-01-31'].products['306013'].postalCodes['08534'].quantity, 4);
      
      //2013 data assert
      assert.equal(result['2013-11-01_2013-11-30'].month, 11);
      assert.equal(result['2013-11-01_2013-11-30'].year, 2013);
      assert.equal(result['2013-11-01_2013-11-30'].firstDate, '2013-11-01');
      assert.equal(result['2013-11-01_2013-11-30'].lastDate, '2013-11-30');
      
      assert.notEqual(result['2013-11-01_2013-11-30'].products['301167'], undefined)
      assert.notEqual(result['2013-11-01_2013-11-30'].products['301167'].postalCodes['15301'], undefined)
      assert.equal(result['2013-11-01_2013-11-30'].products['301167'].manufacturerId, '301167');
      assert.equal(result['2013-11-01_2013-11-30'].products['301167'].postalCodes['15301'].quantity, 2);
      
      //2014 data assert
      assert.equal(result['2014-02-01_2014-02-28'].month, 2);
      assert.equal(result['2014-02-01_2014-02-28'].year, 2014);
      assert.equal(result['2014-02-01_2014-02-28'].firstDate, '2014-02-01');
      assert.equal(result['2014-02-01_2014-02-28'].lastDate, '2014-02-28');
      
      assert.notEqual(result['2014-02-01_2014-02-28'].products['301546'], undefined)
      assert.notEqual(result['2014-02-01_2014-02-28'].products['301546'].postalCodes['23455'], undefined)
      assert.equal(result['2014-02-01_2014-02-28'].products['301546'].manufacturerId, '301546');
      assert.equal(result['2014-02-01_2014-02-28'].products['301546'].postalCodes['23455'].quantity, 8);
      
      //2015 data assert
      assert.equal(result['2015-04-01_2015-04-30'].month, 4);
      assert.equal(result['2015-04-01_2015-04-30'].year, 2015);
      assert.equal(result['2015-04-01_2015-04-30'].firstDate, '2015-04-01');
      assert.equal(result['2015-04-01_2015-04-30'].lastDate, '2015-04-30');
      
      assert.notEqual(result['2015-04-01_2015-04-30'].products['109896'], undefined)
      assert.notEqual(result['2015-04-01_2015-04-30'].products['109896'].postalCodes['21209'], undefined)
      assert.equal(result['2015-04-01_2015-04-30'].products['109896'].manufacturerId, '109896');
      assert.equal(result['2015-04-01_2015-04-30'].products['109896'].postalCodes['21209'].quantity, -4);
      
    })

  })

})
