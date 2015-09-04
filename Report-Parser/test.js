"use strict";

var async = require('async'),
  TCPv2 = require('./parsers/tcp2'),
  xlsx = require('xlsx'),
  _ = require('underscore'),
  jsforce = require('jsforce')

var conn = new jsforce.Connection({
  loginUrl: 'https://test.salesforce.com'
});

var username = 'mark@wylanenergy.com.feature1',
  password = 'Pracedo15!DoldlkeCwdF1Jpiu7jTnaQjT'

var workbook1 = xlsx.readFile('./test/samples/TCPv2/Wylan Energy VA_Wylan Energy_The Home Depot_WYVATHD 2014_20150510_2856071.xls')

var result = TCPv2.parse(workbook1, 'TEST');

result.manufacturer = 'TCP';
result.retailer = 'WALMART';

class SalesforceOrder {
  constructor(order)  {
    var contractId = order.manufacturer + '-' + order.retailer;
    var orderItems = []

    this.request = {
      "order": [{
        "attributes": {
          "type": "Order"
        },
        "EffectiveDate": order.firstDate != null ? order.firstDate : order.lastDate,
        "EndDate": order.lastDate,
        "Status": "Draft",
        "AccountId": "001g000000cW0if",
        "Source_Spreadsheet_Name__c": order.fileName,
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

    if (order.products != null && _.isObject(order.products))
      _.values(order.products)
      .forEach(function (product) {

        if (product.stores != null && _.isObject(product.stores))
          _.values(product.stores)
          .forEach(function (store) {
            orderItems.push({
              "attributes": {
                "type": "OrderItem"
              },
              "PricebookEntry": {
                "Unique__c": contractId + "-" + product.manufacturerId
              },
              "Quantity": store.quantity,
              "UnitPrice": store.totalPrice / store.quantity,
              "Lamps_per_SKU__c": store.lampsPerSku,
              "Location_static__c": store.storeId
            })
          });

        if (product.postalCodes != null && _.isObject(product.postalCodes))
          _.values(product.postalCodes)
          .forEach(function (store) {
            orderItems.push({
              "attributes": {
                "type": "OrderItem"
              },
              "PricebookEntry": {
                "Unique__c": contractId + "-" + product.manufacturerId
              },
              "Quantity": store.quantity,
              "UnitPrice": store.totalPrice / store.quantity,
              "Lamps_per_SKU__c": store.lampsPerSku,
              "PostalCode_static__c": store.storeId
            })
          });
      })

    this.orderItems = orderItems;
  }

  post(cb) {
    var order = this.request,
      orderItems = this.orderItems,
      errors = [];

    order.order[0].OrderItems.records = orderItems.slice(0, 150);

    conn.login(username, password, function (err, userInfo) {
      if (err) return cb(err);

      conn.request({
        method: 'post',
        url: '/services/data/v30.0/commerce/sale/order',
        headers: {
          'Content-Type': 'application/json'
        },
        body: JSON.stringify(order)
      }, function (err, data) {
        if (err) cb(err);
        else if (orderItems.length <= 150) cb(err, data);
        else {
          var batches = [];

          for (var i = 0; i < orderItems.length; i = i + 150) {
            batches.push({
              "order": [{
                "attributes": {
                  "type": "Order"
                },
                "Id": data.records[0].Id,
                "OrderItems": {
                  "records": orderItems.slice(i, i + 150)
                }
              }]
            })
          }

          async.eachLimit(batches, 1, function (order, cb) {

            var body = {
              method: 'patch',
              url: '/services/data/v30.0/commerce/sale/order/' + data.records[0].Id,
              headers: {
                'Content-Type': 'application/json'
              },
              body: order
            };

            console.log(JSON.stringify(body, '', '  '));

            conn.request(body, function (err, data) {
              if (err) {
                errors.push('Could not create extra OrderItems: ' + err.message);
              }
              cb()
            })

          }, function (err) {
            cb(null, errors)
          })
        }
      });

    });
  }
}

var order = new SalesforceOrder(result);

order.post(function (err, result) {
  // if (err) console.log(err.message)
  console.log(result)
})