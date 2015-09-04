var _ = require('underscore')
  , xlsx = require('xlsx')
  , moment = require('moment')

/**
 * Validate if valid HOMEDEPOTSUPPLYv2 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];
  
  if(sheet['A1'] == undefined || !_.isString(sheet['A1'].v) || sheet['A1'].v.trim() != 'Calendar year / week') return false;
  if(sheet['B1'] == undefined || !_.isString(sheet['B1'].v) || sheet['B1'].v.trim() != 'Ship to Postal Code 5 Digit')   return false;
  if(sheet['C1'] == undefined  || !_.isString(sheet['C1'].v) || sheet['C1'].v.trim() != 'SKU')	return false;
  if(sheet['D1'] == undefined  || !_.isString(sheet['D1'].v) || sheet['D1'].v.trim() != 'Description')    return false;
  if(sheet['H1'] == undefined  || !_.isString(sheet['H1'].v) || sheet['H1'].v.trim() != 'Order Start date')    return false;
  if(sheet['I1'] == undefined  || !_.isString(sheet['I1'].v) || sheet['I1'].v.trim() != 'Order End date')    return false;

  return true;
};

/**
 * HOMEDEPOTSUPPLYv2 Module Parsing
 * @param  {Objet}  workbook  Workbook (xlsx)
 * @param  {String} fn        File name
 * @return {Object}           Order object
 */
function parse(workbook, fn, data) {

  if(!isValid(workbook)) return undefined;

  var order = {};
  parseProduct(workbook, order, fn);
  
  return order;
}

function setOrderDate(firstDate, endDate, order) {
	
	order.firstDate = firstDate;
	order.lastDate = endDate;
  
	order.month = parseInt(order.firstDate.split('-')[1])
    order.year = parseInt(order.firstDate.split('-')[0])
}

function getDateFormat(dateString){
	var dateSplit = dateString.split('/');
	return '20' + dateSplit[2] + '-' + (dateSplit[0].length == 1 ? '0' : '') + dateSplit[0] + '-' + (dateSplit[1].length == 1 ? '0' : '') + dateSplit[1];
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(workbook, order, fn) {
	
	var sheet_name_list = workbook.SheetNames;
	//read all sheets from Workbook
	sheet_name_list.forEach(function(sheetName) { 
		var sheet = workbook.Sheets[sheetName];
	
		  //read product by manufacturer id
		  for(var row = 1; row < 100000; row++) {
		    var cellPostcode 		= xlsx.utils.encode_cell({ c: 1, r: row}),
		    	cellManufacturerId 	= xlsx.utils.encode_cell({ c: 2, r: row}),
		    	cellDescription2 	= xlsx.utils.encode_cell({ c: 3, r: row}),
		    	cellDescription1 	= xlsx.utils.encode_cell({ c: 4, r: row}),
		    	cellQuantity 		= xlsx.utils.encode_cell({ c: 5, r: row}),
		    	cellFirstDate 		= xlsx.utils.encode_cell({ c: 7, r: row}),
		    	cellEndDate 		= xlsx.utils.encode_cell({ c: 8, r: row});
		    
		    if(sheet[cellManufacturerId] == undefined || sheet[cellFirstDate] == undefined) break;
		    if(sheet[cellQuantity] == undefined || sheet[cellQuantity].v == 0) continue;
		    
		    var manufacturerId 		= sheet[cellManufacturerId].w,
		    	postCode 			= sheet[cellPostcode].v,
		    	description1		= sheet[cellDescription1].v,
		    	description2		= sheet[cellDescription2].v,
		    	quantity			= sheet[cellQuantity].v,
		    	firstDate			= getDateFormat(sheet[cellFirstDate].w),
		    	endDate				= getDateFormat(sheet[cellEndDate].w);
		    
		    var orderUniqueKey		= firstDate + '_' + endDate;
		    //not yet exist order
		    if(!order[orderUniqueKey]){
		    	order[orderUniqueKey] = {products: {}};
		    	order[orderUniqueKey].fileName = fn + '_' + orderUniqueKey;
		    	setOrderDate(firstDate, endDate, order[orderUniqueKey]);
		    }
		    
		    //not yet exist products[manufacturerId]
		    if(!order[orderUniqueKey].products[manufacturerId]){
		    	order[orderUniqueKey].products[manufacturerId] = {
			      manufacturerId : manufacturerId,
			      description1 : description1,
			      description2 : description2,
			      postalCodes: {}
			    }
		    }
		    
		    //not yet exist products[manufacturerId].postalCodes[postCode]
		    if(!order[orderUniqueKey].products[manufacturerId].postalCodes[postCode]){
		    	order[orderUniqueKey].products[manufacturerId].postalCodes[postCode] = {
		    		postalCode: postCode,
		  	        quantity: quantity,
		    	}
		    //roll up the value of quantity & price for existing postCode
		    }else{
		    	order[orderUniqueKey].products[manufacturerId].postalCodes[postCode].quantity += quantity;
		    	order[orderUniqueKey].products[manufacturerId].postalCodes[postCode].totalPrice += quantity;
		    }
		    
		    //not yet exist products[manufacturerId].postalCodes[postCode]
		    if(!order[orderUniqueKey].products[manufacturerId].postalCodes[postCode]){
		    	order[orderUniqueKey].products[manufacturerId].postalCodes[postCode] = {
		    		postalCode: postCode,
		  	        quantity: quantity,
		    	}
		    //roll up the value of quantity & price for existing postCode
		    }else{
		    	order[orderUniqueKey].products[manufacturerId].postalCodes[postCode].quantity += quantity;
		    }
		  }
	});
}

exports.isValid = isValid;
exports.parse = parse;
