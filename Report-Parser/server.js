var mailin = require('mailin'),
  _ = require('underscore'),
  xlsx = require('xlsx'),
  async = require('async'),
  TCPv1 = require('./parsers/tcp1'),
  TCPv2 = require('./parsers/tcp2'),
  TCPv3 = require('./parsers/TCPv3'),
  TCPv4 = require('./parsers/TCPv4'),
  HOMEDEPOTSUPPLYv1 = require('./parsers/HOMEDEPOTSUPPLYv1'),
  HOMEDEPOTSUPPLYv2 = require('./parsers/HOMEDEPOTSUPPLYv2'),
  GEv1 = require('./parsers/ge'),
  GEv2 = require('./parsers/GEv2'),
  FEITv1 = require('./parsers/feit'),
  PHILIPPSv1 = require('./parsers/PHILIPPSv1'),
  PHILIPPSv2 = require('./parsers/PHILIPPSv2'),
  PHILIPPSv3 = require('./parsers/PHILIPPSv3'),
  mailgunPkg = require('mailgun-js'),
  force = require('./force'),
  fs = require('fs'),
  S = require('string')

var parsers = {
  TCPv1: TCPv1,
  TCPv2: TCPv2,
  TCPv3: TCPv3,
  TCPv4: TCPv4,
  HOMEDEPOTSUPPLYv1: HOMEDEPOTSUPPLYv1,
  HOMEDEPOTSUPPLYv2: HOMEDEPOTSUPPLYv2,
  GEv1: GEv1,
  GEv2: GEv2,
  FEITv1: FEITv1,
  PHILIPPSv1: PHILIPPSv1,
  PHILIPPSv2: PHILIPPSv2,
  PHILIPPSv3: PHILIPPSv3
}

var mailgun = mailgunPkg({
  apiKey: 'key-dbf13c7269a0911512cb93be193327bd',
  domain: 'sandbox637f1ff8800e4c8d9ab704f54c1f0aaf.mailgun.org'
})

mailin.start({
  port: 25,
  disableWebhook: true
});

var verifiedDomains = [
  'pracedo.com',
  'wylanenergy.com'
];

/* Access simplesmtp server instance. */
mailin.on('authorizeUser', function (connection, username, password, done) {
  if (username == "johnsmith" && password == "mysecret") {
    done(null, true);
  } else {
    done(new Error("Unauthorized!"), false);
  }
});

/* Event emitted after a message was received and parsed. */
mailin.on('message', function (connection, data, content) {

  var isToValid = false;

  data.to.forEach(function (item) {
    if (item.address == 'test@middleware.wylanenergy.com') isToValid = true;
  })

  console.log('Processing email sent from ' + data.from[0].address + '...')

  if (data.dkim != 'pass') {
    console.log('DKIM Key is invalid.')
  }

  if (data.from[0].address && _.isString(data.from[0].address)) {
    if (!_.contains(verifiedDomains, data.from[0].address.split('@')[1])) {
      console.log(data.from[0].address.split('@')[1] + ' is an invalid domain.');
      return;
    }
  } else {
    console.log('Cannot find From: address.')
    return;
  }

  console.log('Email sent to a valid To address? ' + (isToValid ? 'Yes' : 'No'))
  if (!isToValid) return;

  fs.writeFile('./email-data/' + Date.now() + '.json', JSON.stringify(data, null, '  '), function (err) {
    if (err) throw err;
  })

  var p = {
    manufacturer: null,
    retailer: null,
    files: [],
    errors: [],
    infos: [],
    data: [],
    email: data
  }

  // Returning Error if no Attachments
  // 
  if (p.email.attachments.length == 0) {
    console.log('Email has no attachment to parse.')
    p.errors.push('Email has no attachment to parse.')
    sendEmail(p);
    return;
  }

  // Checking Manufacturer
  // 
  p.manufacturer = getManufacturerWorkAround(data.text);

  if (p.manufacturer == null)
    p.manufacturer = getManufacturer(content)

  if (p.manufacturer == null) {
    console.log('Cannot detect manufacturer from email sent.')
    p.errors.push('Cannot detect manufacturer from email sent.');
    sendEmail(p);
    return;
  }

  // Checking if any attachments
  // 
  data.attachments.forEach(function (item) {
    var fn = item.fileName;

    if ((!S(fn).endsWith('.xls') && !S(fn).endsWith('.xlsx')) || fn.indexOf('~$') > -1)
      p.infos.push('Ignoring "' + fn + '", since file extension isn\'t ".xls" or ".xlsx".')
    else
      p.files.push(item);
  })

  if (p.files.length == 0) {
    console.log('There are no attachment to handle.');
    p.errors.push('There are no attachment to handle.');
    sendEmail(p);
    return;
  }

  // Getting Retailer
  //
  p.retailer = p.retailer = getRetailerWorkAround(data.text);

  if (p.retailer == null) {
    p.files.forEach(function (item) {
      var fn = item.fileName;

      if (getRetailer(fn) == null) {
        console.log('Cannot find retailer for ' + item.fileName);
        p.errors.push('Cannot find retailer for ' + item.fileName);
      } else
        p.retailer = getRetailer(fn);
    });
  }

  if (p.errors.length != 0) {
    sendEmail(p);
    return;
  }

  console.log('Processing ' + data.subject + ', with ' + p.files.length + ' files related to ' + p.manufacturer + ' and ' + p.retailer + '...');
  readDateFromMailContent(p, data.text);
  process(p);
});

/* Read FirstDate & EndDate from Mainbody if match format */
function readDateFromMailContent(p, mailBody) {
  if (S(mailBody).contains('#startdate:')) {
    p.firstDate = S(mailBody).between('#startdate:', '#').s;
    console.log('Using Workaround for startDate: ' + p.firstDate)
  }

  if (S(mailBody).contains('#enddate:')) {
    p.lastDate = S(mailBody).between('#enddate:', '#').s;
    console.log('Using Workaround for endDate: ' + p.firstDate)
  }
}

function sendEmail(p) {
  var body = 'This email was sent from ' + _.escape(p.email.headers.from) + ' to the middleware.';
  body += '<h2>INFORMATION</h2>';

  body += '<ul>';

  p.infos.forEach(function (item) {
    body += '<li>' + item + '</li>';
  })

  body += '</ul>';

  body += '<h2>ERROR</h2>';

  body += '<ul>';

  p.errors.forEach(function (item) {
    body += '<li>' + item + '</li>';
  })

  body += '</ul>';

  body += '<h2>FILES</h2>';

  body += '<ul>';

  p.files.forEach(function (item) {
    body += '<li>' + item.fileName + '</li>';
  })

  body += '</ul>';

  body += '<table><tr><td>Manufacturer:</td><td>' + p.manufacturer + '</td></tr>';
  body += '<tr><td>Retailer:</td><td>' + p.retailer + '</td></tr></table>';

  var content = {
    from: 'WylanEnergy Middleware <middleware@middleware.wylanenergy.com>',
    // to: p.email.headers.from,
    to: 'salesforce@wylanenergy.com',
    subject: 'Middleware Parsing Result: ' + p.email.subject,
    html: body
  };

  var attachments = [];

  if (_.isString(p.email.text)) {
    console.log('--> Attaching email body...');
    attachments.push(new mailgun.Attachment({
      data: new Buffer(p.email.text),
      filename: 'email-body.txt'
    }));
  }

  if (_.isArray(p.queries))
    p.queries.forEach(function (item) {
      attachments.push(new mailgun.Attachment({
        data: new Buffer(JSON.stringify(item, null, '  ')),
        filename: item.order[0].Source_Spreadsheet_Name__c + '.json'
      }));
    });

  if (attachments.length > 0)
    content.attachment = attachments;

  mailgun.messages().send(content, function (error, body) {
    console.log(body);
  });
}

function getRetailerWorkAround(data)  {
  var content = data.toLowerCase();

  if (S(content).contains('#retailer:costco#')) return 'COSTCO';
  else if (S(content).contains('#retailer:ahold#')) return 'AHOLD';
  else if (S(content).contains('#retailer:sams#')) return 'SAMS';
  else if (S(content).contains('#retailer:target#')) return 'TARGET';
  else if (S(content).contains('#retailer:walmart#')) return 'WALMART';
  else if (S(content).contains('#retailer:homedepot#')) return 'HOMEDEPOT';
  else if (S(content).contains('#retailer:biglots#')) return 'BLS';
  else return null;
}

function getManufacturerWorkAround(data)  {
  var content = data.toLowerCase();

  if (S(content).contains('#manufacturer:tcp#')) return 'TCP';
  else if (S(content).contains('#manufacturer:ge#')) return 'GE';
  else if (S(content).contains('#manufacturer:homedepotsupply#')) return 'HOMEDEPOTSUPPLY';
  else if (S(content).contains('#manufacturer:feit#')) return 'FEIT';
  else if (S(content).contains('#manufacturer:philips#')) return 'PHILIPS';
  else return null;
}

function getRetailer(fn) {
  var costco = 'COSTCO',
    ahold = 'AHOLD',
    sams = 'SAMS',
    target = 'TARGET',
    walmart = 'WALMART',
    bls = 'BLS',
    homeDepot = 'HOMEDEPOT'

  if (fn.indexOf('Costco') > -1) return costco;
  else if (fn.indexOf('AHOLD_POS') > -1) return ahold;
  else if (fn.indexOf('Ahold') > -1) return ahold;
  else if (fn.indexOf('SAMS_POS') > -1) return sams;
  else if (fn.indexOf('Sams') > -1) return sams;
  else if (fn.indexOf('_Sams_') > -1) return sams;
  else if (fn.indexOf('TARGET_POS') > -1) return target;
  else if (fn.indexOf('_Target_') > -1) return target;
  else if (fn.indexOf('target') > -1) return target;
  else if (fn.indexOf('WALMART_POS') > -1) return walmart;
  else if (fn.indexOf('WM_POS') > -1) return walmart;
  else if (fn.indexOf('-WM POS') > -1) return walmart;
  else if (fn.indexOf('_Walmart_') > -1) return walmart;
  else if (fn.indexOf('Walmart') > -1) return walmart;
  else if (fn.indexOf('_BLS') > -1) return bls;
  else if (fn.indexOf('_HomeDepot_') > -1) return homeDepot;
  else if (fn.indexOf('homedepot') > -1) return homeDepot;
  else if (fn.indexOf('_THD_') > -1) return homeDepot;
  else return null;
}

function getManufacturer(content) {
  if (content.indexOf('@tcpi.com') > -1) return 'TCP';
  else if (content.indexOf('@ge.com') > -1) return 'GE';
  else if (content.indexOf('@feit.com') > -1) return 'FEIT';
  else if (content.indexOf('@philips.com') > -1) return 'PHILIPS';
  else return null;
}

function process(data) {
  data.files.forEach(function (item) {

    var result = undefined;
    var workbook = xlsx.read(item.content, {
      type: 'buffer'
    })

    _.allKeys(parsers).forEach(function (parser) {
      if (parsers[parser].isValid(workbook)) {
        if (parser == 'HOMEDEPOTSUPPLYv2') {
          result = parsers[parser].parse(workbook, item.fileName, data);
          if (_isObject(result))
            result = _.values(result);
        } else
          result = parsers[parser].parse(workbook, item.fileName, data);
      }
    })

    if (result == undefined)
      data.errors.push('Cannot parse ' + item.fileName + ' using the ' + data.manufacturer + ' parser.');
    else
      data.data.push(result)

  })

  if (data.data.length == 0) {
    sendEmail(data);
  } else {
    force.send(data, function (err, res, queries) {
      data.errors.push.apply(data.errors, res);
      console.log('force.send err: ' + err)
      console.log('force.send res: ' + res)
      data.queries = queries;
      sendEmail(data);
    });
  }
}