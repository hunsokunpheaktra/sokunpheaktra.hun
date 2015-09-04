var _ = require('underscore')
  , xlsx = require('xlsx')
  , moment = require('moment')

/**
 * Validate if valid PHILIPPSv3 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];

  if(sheet['C2'] == undefined || !_.isString(sheet['C2'].v) || sheet['C2'].v.trim() != 'Store ID')  return false;
  if(sheet['D2'] == undefined || !_.isString(sheet['D2'].v) || sheet['D2'].v.trim() != 'Store Name')   return false;

  return true;
};

/**
 * PHILIPPSv3 Module Parsing
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
  var cellDate1 = xlsx.utils.encode_cell({ c: 4, r: 1 })
    , cellDate2 = xlsx.utils.encode_cell({ c: 6, r: 1 })
    , cellDate3 = xlsx.utils.encode_cell({ c: 8, r: 1 })
    , cellDate4 = xlsx.utils.encode_cell({ c: 10, r: 1 })
    , sheetDates = [];

  var date1 = sheet[cellDate1].w.split(' ')[0].split('/')
  var date2 = sheet[cellDate2].w.split(' ')[0].split('/')
  var date3 = sheet[cellDate3].w.split(' ')[0].split('/')
  var date4 = sheet[cellDate4].w.split(' ')[0].split('/')

  sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  sheetDates.push(new Date('20' + date2[2], date2[0] - 1, date2[1]));
  sheetDates.push(new Date('20' + date3[2], date3[0] - 1, date3[1]));
  sheetDates.push(new Date('20' + date4[2], date4[0] - 1, date4[1]));

  sheetDates.sort();

  order.firstDate = moment(sheetDates[0]).format('YYYY-MM-DD')
  order.lastDate = moment(sheetDates[3]).format('YYYY-MM-DD')

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

  for(var row = 3; row < 100000; row++) {
    var cellManufacturerId = xlsx.utils.encode_cell({ c: 0, r: row});

    if(sheet[cellManufacturerId] == undefined) break;

    var manufacturerId = sheet[cellManufacturerId].w;

    products[manufacturerId] = {
      manufacturerId: manufacturerId,
      stores: {}
    }

    for(var prow = row; prow < 100000; prow++) {
      var cellStoreId = xlsx.utils.encode_cell({ c: 2, r: prow })
        , cellQuantity = xlsx.utils.encode_cell({ c: 12, r: prow })
        , cellTotalPrice = xlsx.utils.encode_cell({ c: 13, r: prow })

      if(sheet[cellStoreId] == undefined) {
        row = prow + 1;
        break;
      }
      if(sheet[cellQuantity].v != 0)
        products[manufacturerId].stores[sheet[cellStoreId].v] = {
             storeId: sheet[cellStoreId].v,
            quantity: sheet[cellQuantity].v,
          totalPrice: sheet[cellTotalPrice].v
        }
    }

  }
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
