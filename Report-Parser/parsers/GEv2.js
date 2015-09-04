var _ = require('underscore')
  , xlsx = require('xlsx')

function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];

  if(sheet['A1'] == undefined || !_.isString(sheet['A1'].v) || sheet['A1'].v.trim() != 'Sub#')                 return false;
  if(sheet['B1'] == undefined || !_.isString(sheet['B1'].v) || sheet['B1'].v.trim() != 'UPN')                  return false;
  if(sheet['C1'] == undefined || !_.isString(sheet['C1'].v) || sheet['C1'].v.trim() != 'Utility Program Name') return false;
  if(sheet['D1'] == undefined || !_.isString(sheet['D1'].v) || sheet['D1'].v.trim() != 'Utility Name')         return false;
  if(sheet['E1'] == undefined || !_.isString(sheet['E1'].v) || sheet['E1'].v.trim() != 'MOU Name')             return false;
  if(sheet['F1'] == undefined || !_.isString(sheet['F1'].v) || sheet['F1'].v.trim() != 'Retail Account')       return false;
  if(sheet['G1'] == undefined || !_.isString(sheet['G1'].v) || sheet['G1'].v.trim() != 'Retailer Name')        return false;
  if(sheet['A3'] == undefined || !_.isString(sheet['A3'].v) || sheet['A3'].v.trim() != 'Begin Date Range')     return false;

  return true;
};

/**
 * GEv1 Module Parsing
 * @param  {Objet}  workbook  Workbook (xlsx)
 * @param  {String} fn        File name
 * @return {Object}           Order object
 */
function parse(workbook, fn, data) {

  if(!isValid(workbook)) return undefined;

  var firstSheetName = workbook.SheetNames[0]
    , sheet = workbook.Sheets[firstSheetName]
    , order = { products: [] }

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
  var cellDate = xlsx.utils.encode_cell({ c: 0, r: 3})
    , cellDate2 = xlsx.utils.encode_cell({ c: 1, r: 3})
    , sheetDate = sheet[cellDate].w.split('/')
    , sheetDateEnd = sheet[cellDate2].w.split('/')

  order.firstDate = '20' + sheetDate[2] + '-' + (sheetDate[0].length == 1 ? '0' : '') + sheetDate[0] + '-' + (sheetDate[1].length == 1 ? '0' : '') + sheetDate[1]
  order.lastDate  = '20' + sheetDateEnd[2] + '-' + (sheetDateEnd[0].length == 1 ? '0' : '') + sheetDateEnd[0] + '-' + (sheetDateEnd[1].length == 1 ? '0' : '') + sheetDateEnd[1]

  order.month = parseInt(sheetDate[0])
  order.year = parseInt('20' + sheetDate[2])
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order) {
  var flats = [];

  for(var i = 3; i < 100000; i++) {
    // Stop if EOF
    if(formatValue(sheet, 2, i) == undefined) break;

    // Skip if Quantity = 0
    if(formatValue(sheet, 7, i) == 0) continue;
    
    var flat = {
                         storeNo: formatValue(sheet, 2, i),
                     productCode: formatValue(sheet, 3, i),
              productDescription: formatValue(sheet, 4, i),
             customerProductCode: formatValue(sheet, 5, i),
      customerProductDescription: formatValue(sheet, 6, i),
                        quantity: formatValue(sheet, 7, i),
            utilityDollarPerUnit: formatValue(sheet, 8, i),
                             uom: formatValue(sheet, 9, i),
                totalIncentitive: formatValue(sheet, 10, i),
                       lampsSold: formatValue(sheet, 11, i),
                         packQty: formatValue(sheet, 12, i),
                    regularPrice: formatValue(sheet, 13, i)
    }
    flats.push(flat);
  }

  var products = {};

  flats.forEach(function(item) {
    if(!(item.productCode in products)) {
      products[item.productCode] = {
        manufacturerId: item.productCode,
        description1: item.productDescription,
        description2: item.customerProductDescription,
        stores: {}
      }
    }

    products[item.productCode].stores[item.storeNo] = {
         storeId: item.storeNo,
        quantity: item.quantity,
     lampsPerSku: item.packQty,
      totalPrice: item.totalIncentitive
    }
  });

  order.products = products;
}

function formatValue(sheet, c, r) {
  var ref = xlsx.utils.encode_cell({ c: c, r: r});

  var data = sheet[ref];

  if(data != undefined) {
    if(typeof(data.v) != "boolean" && !isNaN(data.v))
      return parseFloat(data.v);
    else if(_.isString(data.v))
      return data.v.trim();
    else
      return data.v;
  }
  else
    return undefined;
}

exports.isValid = isValid;
exports.parse = parse;