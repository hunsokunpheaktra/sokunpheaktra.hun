var jsforce = require('jsforce'),
  _ = require('underscore'),
  async = require('async')

var conn = new jsforce.Connection({
  loginUrl: 'https://test.salesforce.com'
});

var username = 'mark@wylanenergy.com.feature1',
  password = 'Pracedo15!DoldlkeCwdF1Jpiu7jTnaQjT'

/**
 * Posting Order to Salesforce
 * @param {Object}   order Order JSON body
 * @param {Function} cb    Callback function
 */
var addOrder = function (order, cb) {

  conn.login(username, password, function (err, userInfo) {
    if (err) return cb(err);

    conn.apex.post("/services/data/v30.0/commerce/sale/order", order, function (err, res) {
      if (err) {
        cb(err);
        return;
      }
      cb(null, res)
    });

  });

};

/**
 * Patching existing Order in Salesforce
 * @param {Object}   order Order JSON body
 * @param {Function} cb    Callback function
 */
var addOrderItems = function (order, cb) {

  var orderId = order.order[0].Id;

  conn.login(username, password, function (err, userInfo) {
    if (err) cb(err);
    else {
      order.order[0].OrderItems.records.forEach(function (orderItem) {
        orderItem.OrderId = orderId;
      })

      conn.apex.patch("/services/data/v30.0/commerce/sale/order/" + orderId, order, function (err, res) {
        if (err) cb(err);
        else cb(null, res)
      });
    }

  });

};

/**
 * Sending Order Data to Salesforce
 * @param  {Object}   data Data object
 * @param  {Funciton} cb   Callback
 */
var send = function (data, cb) {

  var batches = [],
    errors = [];

  createOrderBatches(batches, data);

  console.log('=== Processing following orders... ===')

  async.eachLimit(batches, 1, function (order, cb) {

    var orderItems = order.order[0].OrderItems.records;

    console.log('Order ' + order.order[0]['Source_Spreadsheet_Name__c'] + ' with ' + orderItems.length + ' Order Items...');

    order.order[0].OrderItems.records = orderItems.slice(0, 150);

    addOrder(order, function (err, res) {
      console.log('AddOrder Error (if any): ' + err)
      if (err) {
        errors.push('Could not create Order for ' + order.order[0]['Source_Spreadsheet_Name__c'] + ': ' + err.message);
        cb()
      } else if (orderItems.length <= 150) cb(null)
      else processExtraItems(orderItems, res, function (err, res) {
        if (err) errors.push.apply(errors, res);
        cb()
      })
    })

  }, function (err) {
    cb(null, errors, batches)
  })

}

/**
 * Creating Order Batches
 * @param  {Array}  batches
 * @param  {Object} orderData
 */
function createOrderBatches(batches, data) {

  data.data.forEach(function (item) {
    var contractId = data.manufacturer + '-' + data.retailer,
      orderItems = [];

    var body = {
      "order": [{
        "attributes": {
          "type": "Order"
        },
        "EffectiveDate": item.firstDate != null ? item.firstDate : item.lastDate,
        "EndDate": item.lastDate,
        "Status": "Draft",
        "AccountId": "001g000000cW0if",
        "Source_Spreadsheet_Name__c": item.fileName,
        "Contract": {
          "Unique__c": contractId
        },
        "Pricebook2": {
          "Unique__c": contractId
        },
        "OrderItems": {
          "records": []
        }
      }]
    };

    // console.log(body.order[0])

    _.values(item.products)
      .forEach(function (product) {

        if (_.isObject(product.stores))
          _.values(product.stores)
          .forEach(function (entry) {

            body.order[0]['OrderItems']['records'].push({
              "attributes": {
                "type": "OrderItem"
              },
              "PricebookEntry": {
                "Unique__c": contractId + "-" + product.manufacturerId
              },
              "Quantity": entry.quantity,
              "UnitPrice": entry.totalPrice / entry.quantity,
              "Lamps_per_SKU__c": entry.lampsPerSku,
              "Location_static__c": entry.storeId
            })

          });

        if (_.isObject(product.postalCodes))
          _.values(product.postalCodes)
          .forEach(function (entry) {

            body.order[0]['OrderItems']['records'].push({
              "attributes": {
                "type": "OrderItem"
              },
              "PricebookEntry": {
                "Unique__c": contractId + "-" + product.manufacturerId
              },
              "Quantity": entry.quantity,
              "UnitPrice": entry.totalPrice / entry.quantity,
              "Lamps_per_SKU__c": entry.lampsPerSku,
              "PostalCode_static__c": entry.storeId
            })

          });

      })
    batches.push(body);
  })
}

/**
 * Processing Extra Order Items
 * @param  {Array}   orderItems List of OrderItems
 * @param  {Object}   res       HTTP Call Response
 * @param  {Function} cb        Callback
 */
function processExtraItems(orderItems, res, cb) {
  var orderId = res.records[0].Id,
    orderItemsLeft = orderItems.slice(150, orderItems.length);

  var updateBody = {
    "order": [{
      "attributes": {
        "type": "Order"
      },
      "Id": orderId,
      "OrderItems": {
        "records": []
      }
    }]
  };

  var batches = [];

  var errors = [];

  for (var i = 0; i < orderItemsLeft.length; i = i + 150) {
    batches.push({
      "order": [{
        "attributes": {
          "type": "Order"
        },
        "Id": orderId,
        "OrderItems": {
          "records": orderItemsLeft.slice(i, i + 150)
        }
      }]
    })
  }

  async.eachLimit(batches, 1, function (order, cb) {

    addOrderItems(order, function (err, res) {
      console.log('AddOrderItems Error (if any): ' + err)
      if (err) {
        errors.push('Could not create extra OrderItems: ' + err.message);
      }
      cb()
    })

  }, function (err) {
    cb(null, errors)
  })
}

module.exports.send = send;