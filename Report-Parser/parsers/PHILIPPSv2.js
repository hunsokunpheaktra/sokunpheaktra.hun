var _ = require('underscore')
  , xlsx = require('xlsx')
  , moment = require('moment')

/**
 * Validate if valid PHILIPPSv2 format
 * @param  {Order}  workbook   Workbook (xlsx)
 * @return {Boolean}           Returns true if valid
 */
function isValid(workbook) {
  var sheet = workbook.Sheets[workbook.SheetNames[0]];
  
  if(sheet['B4'] == undefined || !_.isString(sheet['B4'].v) || sheet['B4'].v.trim() != 'PROGRAM START')  return false;
  if(sheet['B5'] == undefined || !_.isString(sheet['B5'].v) || sheet['B5'].v.trim() != 'PROGRAM END')   return false;
  if(sheet['B24'] == undefined || !_.isString(sheet['B24'].v) || sheet['B24'].v.trim() != 'BL SKU #\'S')   return false;

  return true;
};

/**
 * PHILIPPSv1 Module Parsing
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
  
	var cellDate1 = xlsx.utils.encode_cell({ c: 5, r: 23 }),
		cellDate2 = xlsx.utils.encode_cell({ c: 6, r: 23 });
	
	//find endDate of sheet
	for(var col=6;col<100;col++){
		if(sheet[cellDate2].v == 'Total:'){
			cellDate2 = xlsx.utils.encode_cell({ c: col-2, r: 23 });
			break;
		}
		cellDate2 = xlsx.utils.encode_cell({ c: col, r: 23 });
	}
  var startDate = sheet[cellDate1].w.split('-')[0].split('/')
  var endDate = sheet[cellDate2].w.split('-')[1].split('/')
  
  order.firstDate = '20' + startDate[2] + '-' + (startDate[0].length == 1 ? '0' : '') + startDate[0] + '-' + (startDate[1].length == 1 ? '0' : '') + startDate[1];
  order.lastDate = '20' + endDate[2] + '-' + (endDate[0].length == 1 ? '0' : '') + endDate[0] + '-' + (endDate[1].length == 1 ? '0' : '') + endDate[1];
  
  order.month = parseInt(startDate[0])
  order.year = parseInt('20' + startDate[2])
  
}

/**
 * Parsing products from the Excel Sheet
 * @param  {Object} sheet
 * @param  {Object} order
 */
function parseProduct(sheet, order) {

  var products = {}

  //read product by manufacturer id
  for(var row = 25; row < 10000; row++) {
    var cellManufacturerId = xlsx.utils.encode_cell({ c: 1, r: row}),
    	cellItem = xlsx.utils.encode_cell({ c: 3, r: row}),
    	cellDescription = xlsx.utils.encode_cell({ c: 4, r: row});
    
    if(sheet[cellManufacturerId] == undefined) break;
    
    var manufacturerId = sheet[cellManufacturerId].w

    products[manufacturerId] = {
      manufacturerId : manufacturerId,
      description1 : sheet[cellItem].v,
      description2 : sheet[cellDescription] == undefined ? '' : sheet[cellDescription].v,
      stores: {}
    }
    
    //read store data by store id
    for(var prow = row; prow < 10000; prow++) {
    	var cellStoreId = xlsx.utils.encode_cell({ c: 2, r: prow })
        , cellQuantity
        , cellTotalPrice
        , cellHeader;
    	
    	//find total columns data
    	for(var col = 5; col < 100 ; col++){
    		cellHeader = xlsx.utils.encode_cell({ c: col, r: 23 })
    		if(sheet[cellHeader].v == 'Total:'){
    			cellQuantity = xlsx.utils.encode_cell({ c: col, r: prow });
        		cellTotalPrice = xlsx.utils.encode_cell({ c: col+1, r: prow });
        		break;
    		}
    	}
    	if(sheet[cellStoreId] == undefined || _.isString(sheet[cellStoreId].v)) {
    		row = prow + 3;
    		break;
    	}
    	if(sheet[cellQuantity].v != 0){
    		//check if productCode & storeNo duplicate
    		if(products[manufacturerId].stores[sheet[cellStoreId].v]){
    			var oldData = products[manufacturerId].stores[sheet[cellStoreId].v];
    			oldData.quantity += sheet[cellQuantity].v;
    			oldData.totalPrice += sheet[cellTotalPrice].v.toFixed(2);
    		}else{
	            products[manufacturerId].stores[sheet[cellStoreId].v] = {
	                 storeId: sheet[cellStoreId].v,
	                quantity: sheet[cellQuantity].v,
	              totalPrice: sheet[cellTotalPrice].v.toFixed(2)
	        	}
    		}
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
