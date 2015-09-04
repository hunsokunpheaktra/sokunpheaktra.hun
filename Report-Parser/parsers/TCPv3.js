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

  if(sheet['A3'] == undefined || !_.isString(sheet['A3'].v) || sheet['A3'].v.trim() != 'BYO')     return false;
  if(sheet['B3'] == undefined || !_.isString(sheet['B3'].v) || sheet['B3'].v.trim() != 'MKT')     return false;
  if(sheet['C3'] == undefined || !_.isString(sheet['C3'].v) || sheet['C3'].v.trim() != 'STORE #') return false;
  if(sheet['D3'] == undefined || !_.isString(sheet['D3'].v) || sheet['D3'].v.trim() != 'CITY')    return false;
  if(sheet['E3'] == undefined || !_.isString(sheet['E3'].v) || sheet['E3'].v.trim() != 'STATE')   return false;
  if(sheet['F3'] == undefined || !_.isString(sheet['F3'].v) || sheet['F3'].v.trim() != 'UTILITY') return false;
  if(sheet['G1'] == undefined || !_.isString(sheet['G1'].v) || sheet['G1'].v.trim().indexOf('Week Ending') == -1) return false;

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
  var sheetDate = sheet['G1'].v.split(' ')[sheet['G1'].v.split(' ').length-1].split('/')

  order.lastDate = '20' + sheetDate[2] + '-' + (sheetDate[0].length == 1 ? '0' : '') + sheetDate[0] + '-' + (sheetDate[1].length == 1 ? '0' : '') + sheetDate[1]
  order.firstDate = moment(order.lastDate).subtract(7, 'day').format('YYYY-MM-DD');

  order.month = parseInt(sheetDate[0])
  order.year = parseInt('20' + sheetDate[2])
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order) {
  for(var col = 6; col < 100000; col = col + 3) {
    var productSku = formatValue(sheet, col, 1);

    if(_.isString(productSku))
      productSku = productSku.split(' ')[0]

    if(productSku == 'Total' || productSku == null)
      break;

    var stores = {}

    for(var y = 3; y < 10000; y++) {
      var storeNo = formatValue(sheet, 2, y);

      if(storeNo == null || !_.isNumber(storeNo)) break;

      var store = {
           storeId: storeNo,
          quantity: formatValue(sheet, col, y),
       // lampsPerSku: formatValue(sheet, col+1, y),
        totalPrice: formatValue(sheet, col+2, y).toFixed(2)
      }

      if(store.quantity != 0) {
        store.lampsPerSku = formatValue(sheet, col+1, y) / store.quantity, -1

        stores[store.storeId] = store
      }
    }

    var product = {
      manufacturerId: productSku,
        // description1: productSku,
        // description2: productName,
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
    else if(_.isString(data.v))
      return data.v.trim();
    else
      return data.v;
  }
  else
    return undefined;
}

exports.isValid = isValid;
exports.parse   = parse;