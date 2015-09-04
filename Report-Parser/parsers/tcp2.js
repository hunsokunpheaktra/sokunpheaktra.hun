var _ = require('underscore')
  , xlsx = require('xlsx')
  , moment = require('moment')

/**
 * Validate if valid TCPv1 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];

  if(sheet['A10'] == undefined || !_.isString(sheet['A10'].v) || sheet['A10'].v.trim() != 'Invoice') return false;
  if(sheet['C10'] == undefined || !_.isString(sheet['C10'].v) || sheet['C10'].v.trim() != 'Store')   return false;
  if(sheet['E10'] == undefined || !_.isString(sheet['E10'].v) || sheet['E10'].v.trim() != 'City')    return false;
  if(sheet['F10'] == undefined || !_.isString(sheet['F10'].v) || sheet['F10'].v.trim() != 'State')   return false;
  if(sheet['H10'] == undefined || !_.isString(sheet['H10'].v) || sheet['H10'].v.trim() != 'Utility') return false;

  return true;
};

/**
 * TCPv1 Module Parsing
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
  var cellDate = xlsx.utils.encode_cell({ c: 1, r: 2})
    , sheetDate = sheet[cellDate].v.split(' ')[sheet[cellDate].v.split(' ').length-1].split('/')

  order.lastDate = sheetDate[2] + '-' + (sheetDate[0].length == 1 ? '0' : '') + sheetDate[0] + '-' + (sheetDate[1].length == 1 ? '0' : '') + sheetDate[1]
  order.firstDate = moment(order.lastDate).subtract(7, 'day').format('YYYY-MM-DD');

  order.month = parseInt(sheetDate[0])
  order.year = parseInt(sheetDate[2])
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order) {
  for(var col = 10; col < 1000; col = col + 3) {
    var productSku = formatValue(sheet, col, 4);

    // Extra column?
    if(!_.isNumber(productSku))
      break;

    var productId   = sheet[xlsx.utils.encode_cell({ c: col, r: 5})].v.trim();
    var productName = sheet[xlsx.utils.encode_cell({ c: col, r: 6})].v.trim();

    var stores = {}

    for(var y = 10; y < 1000; y++) {
      var storeNo = formatValue(sheet, 2, y);

      if(storeNo == undefined || !_.isNumber(storeNo)) break;

      if(formatValue(sheet, col, y) == 0) continue;

      var store = {
           storeId: storeNo,
          quantity: formatValue(sheet, col, y),
       lampsPerSku: formatValue(sheet, col+1, y),
        totalPrice: formatValue(sheet, col+2, y).toFixed(2)
      }

      if(store.quantity != 0)
        stores[store.storeId] = store
    }

    var product = {
      manufacturerId: productId,
        description1: productSku,
        description2: productName,
              stores: stores
    };

    if(_.keys(stores).length > 0)
      order.products[product.manufacturerId] = product
  }
}

function formatValue(sheet, c, r) {
  var ref = xlsx.utils.encode_cell({ c: c, r: r});

  var data = sheet[ref];

  if(data != undefined) {
    if(typeof(data.v) != "boolean" && !isNaN(data.v))
      return parseFloat(data.v);
    else if(_.isString(data.v)) {
      if(data.v.indexOf('$') != -1) {
        data.v = data.v.replace('($', '-').replace('$', '').replace(')', '')

        if(typeof(data.v) != "boolean" && !isNaN(data.v))
          return parseFloat(data.v.trim());
        else
          return data.v.trim();
      }
    }
    else
      return data.v;
  }
  else
    return undefined;
}

exports.isValid = isValid;
exports.parse   = parse;