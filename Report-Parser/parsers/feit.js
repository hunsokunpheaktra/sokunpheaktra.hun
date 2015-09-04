var _ = require('underscore')
  , xlsx = require('xlsx')

/**
 * Validate if valid TCPv1 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];

  if(sheet['B4'] == undefined || !_.isString(sheet['B4'].v) || sheet['B4'].v.trim() != 'WHSE')  return false;
  if(sheet['C4'] == undefined || !_.isString(sheet['C4'].v) || sheet['C4'].v.trim() != 'CPN')   return false;
  if(sheet['D4'] == undefined || !_.isString(sheet['D4'].v) || sheet['D4'].v.trim() != 'ITEM')  return false;
  if(sheet['E4'] == undefined || !_.isString(sheet['E4'].v) || sheet['E4'].v.trim() != 'MODEL') return false;
  if(sheet['F4'] == undefined || !_.isString(sheet['F4'].v) || sheet['F4'].v.trim() != 'PK')    return false;

  var totalTest = false
    , packsTest = false;

  for(var i = 0; i < 2000; i++) {
    var cellId = xlsx.utils.encode_cell({ c: i, r: 3});

    if(sheet[cellId] != undefined && _.isString(sheet[cellId].v) && sheet[cellId].v.trim().indexOf('Total') > -1) totalTest = true;
    if(sheet[cellId] != undefined && _.isString(sheet[cellId].v) && sheet[cellId].v.trim().indexOf('Packs') > -1) packsTest = true;

    if(totalTest && packsTest) break;
  }

  if(!totalTest || !packsTest) return false;

  return true;
};

/**
 * FEITv1 Module Parsing
 * @param  {Objet}  workbook  Workbook (xlsx)
 * @param  {String} fn        File name
 * @return {Object}           Order object
 */
function parse(workbook, fn, data) {
  var firstWeekCol
    , lastWeekCol
    , totalPacksCol

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
	  // We can have 3,4,5 weekly columns. This helps find the latest.
	  for(var i = 0; i < 2000; i++) {
	    var totalPacksCellID = xlsx.utils.encode_cell({ c: i, r: 3});

	    if(firstWeekCol == undefined && sheet[totalPacksCellID] != undefined && _.isString(sheet[totalPacksCellID].v) && sheet[totalPacksCellID].v.indexOf('W/E') > -1) {
	      firstWeekCol = totalPacksCellID;
	    }

	    if(sheet[totalPacksCellID] != undefined && _.isString(sheet[totalPacksCellID].v) && sheet[totalPacksCellID].v.trim().indexOf('Packs') > -1) {
	      totalPacksCol = i;
	      lastWeekCol = i - 2;
	      break;
	    }
	  }
	  parseDate(sheet, order, firstWeekCol, lastWeekCol, totalPacksCol);
  }
  
  parseProduct(sheet, order, firstWeekCol, lastWeekCol, totalPacksCol)

  return order;
}

/**
 * Parsing date from the Excel spreadsheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseDate(sheet, order, firstWeekCol, lastWeekCol, totalPacksCol) {

  var sheetStartDate = sheet[firstWeekCol].v.split(' ')[sheet[firstWeekCol].v.split(' ').length-1].split('/')
    , sheetEndDate = sheet[xlsx.utils.encode_cell({ c: totalPacksCol - 2, r: 3})].v.split(' ')[sheet[xlsx.utils.encode_cell({ c: totalPacksCol - 2, r: 3})].v.split(' ').length-1].split('/');

  order.firstDate = '20' + sheetStartDate[2] + '-' + sheetStartDate[0] + '-' + sheetStartDate[1];
  order.lastDate  = '20' + sheetEndDate[2] + '-' + sheetEndDate[0] + '-' + sheetEndDate[1]

  order.month = parseInt(sheetEndDate[0])
  order.year = parseInt('20' + sheetEndDate[2])
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order, firstWeekCol, lastWeekCol, totalPacksCol) {

  var products = {}

  for(var row = 4; row < 20000; row++) {
    var cellStoreId = xlsx.utils.encode_cell({ c: 1, r: row});

    if(sheet[cellStoreId] == undefined)      continue;
    if(sheet[cellStoreId].w.indexOf('$') > -1) break;

    var storeId = sheet[cellStoreId].v;

    var cpn = formatValue(sheet, 2, row)
      , item = formatValue(sheet, 3, row)
      , model = formatValue(sheet, 4, row)
      , pk = formatValue(sheet, 5, row)
      , totalPacks = formatValue(sheet, totalPacksCol, row)
      , total = formatValue(sheet, totalPacksCol+1, row)

    if(totalPacks == 0) continue;

    if(!(cpn in products)) {
      products[cpn] = {
        manufacturerId: cpn,
        description1: item,
        description2: model,
        stores: {}
      }
    }

    products[cpn].stores[storeId] = {
         storeId: storeId,
        quantity: totalPacks,
     lampsPerSku: pk,
      totalPrice: total
    };
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