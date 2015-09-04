var _ = require('underscore')
  , xlsx = require('xlsx');

/**
 * Validate if valid TCPv1 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook, data) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]]
  
  // Headers
  if(sheet['A8'] == undefined || !_.isString(sheet['A8'].v) || sheet['A8'].v.trim() != 'Store #') return false;
  if(sheet['B8'] == undefined || !_.isString(sheet['B8'].v) || sheet['B8'].v.trim() != 'CITY')    return false;
  if(sheet['C8'] == undefined || !_.isString(sheet['C8'].v) || sheet['C8'].v.trim() != 'STATE')   return false;
  if(sheet['D8'] == undefined || !_.isString(sheet['D8'].v) || sheet['D8'].v.trim() != 'UTILITY') return false;
  //date cell value												 //firstDate & lastDate read from content mail body
  if((sheet['A4'] == undefined || !_.isString(sheet['A4'].v)) && (data != undefined && (data.firstDate == undefined || data.lastDate == undefined))) return false;
  if(sheet['E3'] != undefined && _.isString(sheet['E3'].v) && sheet['E3'].v.trim().indexOf('WE') != -1) return false;
  
  // Column Header - Product
  var colHeader = sheet['E4'];
  if(colHeader == undefined || !_.isNumber(colHeader.v)) return false;
  return true;
};

/**
 * TCPv1 Module Parsing
 * @param  {Objet}  workbook  Workbook (xlsx)
 * @param  {String} fn        File name
 * @return {Object}           Order object
 */
function parse(workbook, fn, data) {

  if(!isValid(workbook, data)) return undefined;

  var firstSheetName = workbook.SheetNames[0]
    , sheet = workbook.Sheets[firstSheetName]
    , order = { products: {} };

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
  var cellDate = 'A4'

  if(sheet[cellDate] != undefined && sheet[cellDate].v.indexOf('.') > -1) {

    var sheetDate = sheet[cellDate].v.split('-')
      , fDate = sheetDate[0].split('.')
      , lDate = sheetDate[1].split('.')

    order.firstDate = '20' + ((fDate.length == 3) ? fDate[2] : lDate[2]) + '-' + (fDate[0].length == 1 ? '0' : '') + fDate[0] + '-' + (fDate[1].length == 1 ? '0' : '') + fDate[1]
    order.lastDate  = '20' + lDate[2] + '-' + (lDate[0].length == 1 ? '0' : '') + lDate[0] + '-' + (lDate[1].length == 1 ? '0' : '') + lDate[1]

    order.month = parseInt(sheetDate[0].split('.')[0])
    order.year = parseInt('20' + ((fDate.length == 3) ? fDate[2] : lDate[2]))

  }
  else if(sheet[cellDate] != undefined) { // AEDE-WM POS WE 7.25.xlsx has / instead of .
    var sheetDate = sheet[cellDate].v.split('-')
      , fDate = sheetDate[0].split('/')
      , lDate = sheetDate[1].split('/')

    order.firstDate = '20' + ((fDate.length == 3) ? fDate[2] : lDate[2]) + '-' + (fDate[0].length == 1 ? '0' : '') + fDate[0] + '-' + (fDate[1].length == 1 ? '0' : '') + fDate[1]
    order.lastDate  = '20' + lDate[2] + '-' + (lDate[0].length == 1 ? '0' : '') + lDate[0] + '-' + (lDate[1].length == 1 ? '0' : '') + lDate[1]

    order.month = parseInt(sheetDate[0].split('.')[0])
    order.year = parseInt('20' + ((fDate.length == 3) ? fDate[2] : lDate[2]))
  }
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order) {
  for(var col = 4; col < 5000; col = col + 3) {
    var cellDescription1 = xlsx.utils.encode_cell({ c: col, r: 3});

    // Extra column?
    if(!_.isNumber(sheet[cellDescription1].v))
      break;

    var cellManufacturerID = xlsx.utils.encode_cell({ c: col, r: 4});
    var cellDescription2   = xlsx.utils.encode_cell({ c: col, r: 5});

    var stores = {}

    for(var y = 8; y < 1000; y++) {
      var storeNo = xlsx.utils.encode_cell({ c: 0, r: y});

      if(sheet[storeNo] == undefined || !_.isNumber(sheet[storeNo].v)) break;

      var city   = xlsx.utils.encode_cell({ c: 1, r: y})
        , state  = xlsx.utils.encode_cell({ c: 2, r: y})
        , skus   = xlsx.utils.encode_cell({ c: col, r: y})
        , lamps  = xlsx.utils.encode_cell({ c: col+1, r: y})
        , rebate = xlsx.utils.encode_cell({ c: col+2, r: y});

      var store = {
            storeId: sheet[storeNo].v,
           quantity: sheet[skus].v,
        lampsPerSku: sheet[lamps].v,
         totalPrice: sheet[rebate].v.toFixed(2)
      }

      if(store.quantity != 0)
        stores[store.storeId] = store;
    }
    
    var product = {
      manufacturerId: sheet[cellManufacturerID].v,
        description1: sheet[cellDescription1].v,
        description2: sheet[cellDescription2].v.trim(),
              stores: stores
    };
    
    if(_.keys(stores).length > 0)
      order.products[product.manufacturerId] = product
  }
}

exports.isValid = isValid;
exports.parse   = parse;
