var _ = require('underscore')
  , xlsx = require('xlsx')
  , moment = require('moment')

/**
 * Validate if valid HOMEDEPOTSUPPLYv1 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];
  
  if(sheet['A3'] == undefined || !_.isString(sheet['A3'].v) || sheet['A3'].v.trim() != 'Billing doc. date') return false;
  if(sheet['B3'] == undefined || !_.isString(sheet['B3'].v) || sheet['B3'].v.trim() != 'Ship to Postal Code 5 Digit')   return false;
  if(sheet['C3'] == undefined  || !_.isString(sheet['C3'].v) || sheet['C3'].v.trim() != 'SKU')	return false;
  if(sheet['D3'] == undefined  || !_.isString(sheet['D3'].v) || sheet['D3'].v.trim() != 'Description')    return false;

  return true;
};

/**
 * HOMEDEPOTSUPPLYv1 Module Parsing
 * @param  {Objet}  workbook  Workbook (xlsx)
 * @param  {String} fn        File name
 * @return {Object}           Order object
 */
function parse(workbook, fn, data) {

  if(!isValid(workbook)) return undefined;

  var firstSheetName = workbook.SheetNames[0]
    , sheet = workbook.Sheets[firstSheetName]
    , order = { products: {} }

  order.fileName = fn;
  
  if(data != undefined && data.firstDate != undefined && data.lastDate != undefined){ 
	  order.firstDate = data.firstDate;
	  order.lastDate = data.lastDate;
	  
	  var sheetDate = order.firstDate.split('-');
	  order.month = parseInt(sheetDate[1])
	  order.year = parseInt(sheetDate[0]);
  }else{
	  parseDate(sheet, order);
  }
  
  parseProduct(sheet, order)

  return order;
}

/**
 * Parsing date from the Excel spreadsheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseDate(sheet, order) {
	
	var sheetDates = [];
	for(var row = 3; row < 100000; row++){
		var cellDate = xlsx.utils.encode_cell({ c: 0, r: row });
		if(sheet[cellDate] == undefined) break;
		var billDate = sheet[cellDate].w;
		var dateVal = billDate.split('/');
		
		sheetDates.push(new Date(dateVal[2], dateVal[0] - 1, dateVal[1]));
	}
	
	order.firstDate = moment(sheetDates[0]).format('YYYY-MM-DD')
	order.lastDate = moment(sheetDates[sheetDates.length-1]).format('YYYY-MM-DD')
  
	order.month = sheetDates[0].getMonth() + 1
	order.year = sheetDates[0].getFullYear()
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order) {

  var products = {}

  //read product by manufacturer id
  for(var row = 3; row < 100000; row++) {
    var cellManufacturerId 	= xlsx.utils.encode_cell({ c: 2, r: row}),
    	cellPostcode 		= xlsx.utils.encode_cell({ c: 1, r: row}),
    	cellDescription2 	= xlsx.utils.encode_cell({ c: 3, r: row}),
    	cellDescription1 	= xlsx.utils.encode_cell({ c: 4, r: row}),
    	cellQuantity 		= xlsx.utils.encode_cell({ c: 5, r: row}),
    	cellPriceIncentive 	= xlsx.utils.encode_cell({ c: 6, r: row})
    
    if(sheet[cellManufacturerId] == undefined) break;
    if(sheet[cellQuantity] == undefined || sheet[cellQuantity].v == 0) continue;
    
    var manufacturerId 	= sheet[cellManufacturerId].w,
    	postCode 		= sheet[cellPostcode].v,
    	description1	= sheet[cellDescription1].v,
    	description2	= sheet[cellDescription2].v,
    	quantity		= sheet[cellQuantity].v,
    	priceIncentive	= parseFloat(sheet[cellPriceIncentive].w.replace('$', '').trim())
    
    //not yet exist products[manufacturerId]
    if(!products[manufacturerId]){
    	products[manufacturerId] = {
	      manufacturerId : manufacturerId,
	      description1 : description1,
	      description2 : description2,
	      postalCodes: {}
	    }
    }
    
    //not yet exist products[manufacturerId].postalCodes[postCode]
    if(!products[manufacturerId].postalCodes[postCode]){
    	products[manufacturerId].postalCodes[postCode] = {
    		postalCode: postCode,
  	        quantity: quantity,
  	        totalPrice: priceIncentive
    	}
    //roll up the value of quantity & price for existing postCode
    }else{
    	products[manufacturerId].postalCodes[postCode].quantity += quantity;
    	products[manufacturerId].postalCodes[postCode].totalPrice += quantity;
    }
  }
  order.products = products;
}

exports.isValid = isValid;
exports.parse = parse;
