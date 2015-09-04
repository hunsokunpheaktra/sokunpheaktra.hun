var _ = require('underscore'),
  xlsx = require('xlsx'),
  moment = require('moment')

/**
 * Validate if valid PHILIPPSv1 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];

  if (sheet['B2'] == undefined || !_.isString(sheet['B2'].v) || sheet['B2'].v.trim() != 'Store ID') return false;
  if (sheet['C2'] == undefined || !_.isString(sheet['C2'].v) || sheet['C2'].v.trim() != 'Store Name') return false;

  return true;
};

/**
 * PHILIPPSv1 Module Parsing
 * @param  {Objet}  workbook  Workbook (xlsx)
 * @param  {String} fn        File name
 * @return {Object}           Order object
 */
function parse(workbook, fn, data) {

  if (!isValid(workbook)) return undefined;

  var firstSheetName = workbook.SheetNames[0],
    sheet = workbook.Sheets[firstSheetName],
    order = {
      products: {}
    }

  order.fileName = fn;

  if (data != undefined && data.firstDate != undefined && data.lastDate != undefined) {
    order.firstDate = data.firstDate;
    order.lastDate = data.lastDate;

    var sheetDate = order.firstDate.split('-');
    order.month = parseInt(sheetDate[1])
    order.year = parseInt(sheetDate[0]);
  } else {
    parseDate(sheet, order);
  }

  parseProduct(sheet, order)

  return order;
}

var cols;

/**
 * Parsing date from the Excel spreadsheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseDate(sheet, order) {
  var cellDate1 = xlsx.utils.encode_cell({
      c: 3,
      r: 1
    }),
    cellDate2 = xlsx.utils.encode_cell({
      c: 5,
      r: 1
    }),
    cellDate3 = xlsx.utils.encode_cell({
      c: 7,
      r: 1
    }),
    cellDate4 = xlsx.utils.encode_cell({
      c: 9,
      r: 1
    }),
    cellDate5 = xlsx.utils.encode_cell({
      c: 11,
      r: 1
    }),
    cellDate6 = xlsx.utils.encode_cell({
      c: 13,
      r: 1
    }),
    sheetDates = [];

  if (sheet[cellDate1]) {
    var date1 = sheet[cellDate1].w.split(' ')[0].split('/')
    sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  }
  if (sheet[cellDate2]) {
    var date1 = sheet[cellDate2].w.split(' ')[0].split('/')
    sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  }
  if (sheet[cellDate3]) {
    var date1 = sheet[cellDate3].w.split(' ')[0].split('/')
    sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  }
  if (sheet[cellDate4]) {
    var date1 = sheet[cellDate4].w.split(' ')[0].split('/')
    sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  }
  if (sheet[cellDate5]) {
    var date1 = sheet[cellDate5].w.split(' ')[0].split('/')
    sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  }
  if (sheet[cellDate6]) {
    var date1 = sheet[cellDate6].w.split(' ')[0].split('/')
    sheetDates.push(new Date('20' + date1[2], date1[0] - 1, date1[1]));
  }

  sheetDates.sort();

  cols = sheetDates.length;

  order.firstDate = moment(sheetDates[0]).format('YYYY-MM-DD')
  order.lastDate = moment(sheetDates[sheetDates.length - 1]).format('YYYY-MM-DD')

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

  for (var row = 3; row < 100000; row++) {
    var cellManufacturerId = xlsx.utils.encode_cell({
      c: 0,
      r: row
    });

    if (sheet[cellManufacturerId] == undefined) break;

    var manufacturerId = sheet[cellManufacturerId].w;

    products[manufacturerId] = {
      manufacturerId: manufacturerId,
      stores: {}
    };

    for (var prow = row; prow < 100000; prow++) {
      var cellStoreId = xlsx.utils.encode_cell({
          c: 1,
          r: prow
        }),
        cellQuantity = xlsx.utils.encode_cell({
          c: (cols * 2) + 3,
          r: prow
        }),
        cellTotalPrice = xlsx.utils.encode_cell({
          c: (cols * 2) + 4,
          r: prow
        })

      if (sheet[cellStoreId] == undefined) {
        row = prow + 1;
        break;
      }

      if (sheet[cellQuantity].v != 0)
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
  var ref = xlsx.utils.encode_cell({
    c: c,
    r: r
  });

  var data = sheet[ref];

  if (data != undefined) {
    if (typeof (data.v) != "boolean" && !isNaN(data.v))
      return parseFloat(data.v);
    else if (_.isString(data.v))
      return data.v.trim();
    else
      return data.v;
  } else
    return undefined;
}

exports.isValid = isValid;
exports.parse = parse;